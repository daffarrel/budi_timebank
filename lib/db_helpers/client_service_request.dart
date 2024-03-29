import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/service_request.dart';
import 'client_user.dart';

class ClientServiceRequest {
  // we cannot make a vvaraible ti store the user uid here, it may be same if we
  // sign in with different account
  /// get summary (total number) for requests
  static Future<(int, int, int, int)> getRequestorSummary() async {
    var serviceRequest = await _getAllRequests();
    var pending = serviceRequest
        .where((element) => element.status == ServiceRequestStatus.pending)
        .length;
    var accepted = serviceRequest
        .where((element) => element.status == ServiceRequestStatus.accepted)
        .length;
    var ongoing = serviceRequest
        .where((element) => element.status == ServiceRequestStatus.ongoing)
        .length;
    var completed = serviceRequest
        .where((element) =>
            element.status == ServiceRequestStatus.completedVerified)
        .length;

    return (pending, accepted, ongoing, completed);
  }

  /// Submits a service request
  static Future<void> submitJob(ServiceRequest serviceRequest) async {
    final CollectionReference serviceRequestCollection =
        FirebaseFirestore.instance.collection('serviceRequests');
    await serviceRequestCollection.add(serviceRequest.toFirestoreMap());
  }

  /// get summary (total number) for services
  /// The number of services you have done to others
  static Future<(int, int, int, int)> getServicesSummary() async {
    var userUid = FirebaseAuth.instance.currentUser!.uid;

    var data = await _getAllServices();

    var pending = data
        .where((element) =>
            element.status == ServiceRequestStatus.pending &&
            element.applicants.contains(userUid))
        .length;
    var accepted = data
        .where((element) =>
            element.status == ServiceRequestStatus.accepted &&
            element.providerId == userUid)
        .length;
    var ongoing = data
        .where((element) =>
            element.status == ServiceRequestStatus.ongoing &&
            element.providerId == userUid)
        .length;
    var completed = data
        .where((element) =>
            element.status == ServiceRequestStatus.completedVerified &&
            element.providerId == userUid)
        .length;

    return (pending, accepted, ongoing, completed);
  }

  /// Get all requests by you without any filtering
  static Future<List<ServiceRequest>> _getAllRequests() async {
    var userUid = FirebaseAuth.instance.currentUser!.uid;

    var snapshot = await FirebaseFirestore.instance
        .collection('serviceRequests')
        .where('requestorId', isEqualTo: userUid)
        .get();

    var snapshotData = snapshot.docs;

    return snapshotData.map((e) {
      var serviceRequest = ServiceRequest.fromJson(e.data());
      serviceRequest.id = e.id;
      return serviceRequest;
    }).toList();
  }

  /// Delete service requests
  static Future<void> deleteServiceRequest(String jobId) async {
    FirebaseFirestore.instance
        .collection('serviceRequests')
        .doc(jobId)
        .delete();
  }

  /// Get pending requests by you (Need help page, 1st tab)
  static Future<List<ServiceRequest>> getPendingRequests() async {
    var userUid = FirebaseAuth.instance.currentUser!.uid;

    var snapshot = await FirebaseFirestore.instance
        .collection('serviceRequests')
        .where('status', isEqualTo: ServiceRequestStatus.pending.name)
        .where('requestorId', isEqualTo: userUid)
        .where('applicants', isEqualTo: []).get();

    var snapshotData = snapshot.docs;

    return snapshotData.map((e) {
      var serviceRequest = ServiceRequest.fromJson(e.data());
      serviceRequest.id = e.id;
      return serviceRequest;
    }).toList();
  }

  /// Need help page, 2nd tab (Applied Request) - Get applied and ongoing requests
  static Future<List<ServiceRequest>> getAppliedServiceRequest() async {
    var userUid = FirebaseAuth.instance.currentUser!.uid;

    var docs = await FirebaseFirestore.instance
        .collection('serviceRequests')
        .where('requestorId', isEqualTo: userUid)
        .where('status', whereIn: [
      ServiceRequestStatus.pending.name,
      ServiceRequestStatus.accepted.name,
      ServiceRequestStatus.ongoing.name
    ]).where('applicants', isNotEqualTo: []).get();

    var data = docs.docs.map((e) {
      var serviceRequest = ServiceRequest.fromJson(e.data());
      serviceRequest.id = e.id;
      return serviceRequest;
    }).toList();

    return data;
  }

  /// Get the completed request (Need help page, 3rd tab)
  static Future<List<ServiceRequest>> getCompletedRequest() async {
    var userUid = FirebaseAuth.instance.currentUser!.uid;

    var dataDocs = await FirebaseFirestore.instance
        .collection('serviceRequests')
        .where('requestorId', isEqualTo: userUid)
        .where(
      'status',
      whereIn: [
        ServiceRequestStatus.completed.name,
        ServiceRequestStatus.completedVerified.name
      ],
    ).where('applicants', isNotEqualTo: []).get();

    return dataDocs.docs.map((e) {
      var serviceRequest = ServiceRequest.fromJson(e.data());
      serviceRequest.id = e.id;
      return serviceRequest;
    }).toList();
  }

  /// Start a service request (triggered from the need help page)
  static Future<void> startService(String serviceRequestId) async {
    await FirebaseFirestore.instance
        .collection('serviceRequests')
        .doc(serviceRequestId)
        .update({
      'status': ServiceRequestStatus.ongoing.name,
      'updatedAt': DateTime.now(),
      'startedAt': DateTime.now()
    });
  }

  /// Mark task as complete (triggered from the offer help > job details page)
  static Future<void> markTaskComplete(String serviceRequestId) async {
    var finishTime = DateTime.now();
    await FirebaseFirestore.instance
        .collection('serviceRequests')
        .doc(serviceRequestId)
        .update({
      'status': ServiceRequestStatus.completed.name,
      'updatedAt': finishTime,
      'completedAt': finishTime
    });
  }

  /// Verifies a service has been completed by the provider (triggered from the need help page)
  static Future<void> verifyServiceCompleted(String serviceRequestId) async {
    var finishTime = DateTime.now();
    await FirebaseFirestore.instance
        .collection('serviceRequests')
        .doc(serviceRequestId)
        .update({
      'status': ServiceRequestStatus.completedVerified.name,
      'updatedAt': finishTime,
      'completedAt': finishTime
    });

    // transfer payments
    var serviceRequest = await getMyServiceRequestById(serviceRequestId);
    var startTime = serviceRequest.startedAt!;

    // Calculate the duration of the service
    // InHours will return the rounded down value of hours. Eg: 1h 30 min will be 1 hour
    // round up the duration to the closest hour
    var duration = finishTime.difference(startTime).inHours + 1;

    // Calculate total payment. If the duration is less than the time limit, then
    // the total payment is the duration * rate. Otherwise, the total payment is
    // the time limit * rate (max)
    double totalPayment =
        (duration + 1).clamp(0, serviceRequest.timeLimit) * serviceRequest.rate;

    await ClientUser.transferPoints(
        serviceRequest.providerId!, totalPayment, serviceRequestId);
  }

  /// Get service payment for job
  static Future<double> getServiceIncome(String jobId) async {
    var allTransaction = await ClientUser.getUserEarningsHistory();
    return allTransaction
        .where((element) => element.reason == 'job:$jobId')
        .first
        .amount;
  }

  static Future<ServiceRequest> getMyServiceRequestById(String id) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('serviceRequests')
        .doc(id)
        .get();

    if (!snapshot.exists) throw Exception("Service Request $id not exist");
    var serviceRequest = ServiceRequest.fromJson(snapshot.data()!);
    serviceRequest.id = snapshot.id;
    return serviceRequest;
  }

  static Future<void> getPendingServicesByCategories(String category) async {
    await FirebaseFirestore.instance
        .collection('serviceRequests')
        .where('status', isEqualTo: ServiceRequestStatus.pending)
        .where('category', isEqualTo: category)
        .get();
  }

  /// Get all available services
  static Future<List<ServiceRequest>> _getAllServices() async {
    var userUid = FirebaseAuth.instance.currentUser!.uid;

    var snapshot = await FirebaseFirestore.instance
        .collection('serviceRequests')
        .where('requestorId', isNotEqualTo: userUid)
        .get();

    var snapshotData = snapshot.docs;

    var data = snapshotData.map((e) {
      var serviceRequest = ServiceRequest.fromJson(e.data());
      serviceRequest.id = e.id;
      return serviceRequest;
    }).toList();

    return data;
  }

  /// Offer help page, first tab (Available request)
  static Future<List<ServiceRequest>> getMyAvailableServices() async {
    var userUid = FirebaseAuth.instance.currentUser!.uid;

    var data = await _getAllServices();

    // local flitering, only return service request that the applicants is not the current user
    // current limitatio of Firestore is we don't something like arrayNotContains
    return data
        .where((element) =>
            element.status == ServiceRequestStatus.pending &&
            !element.applicants.contains(userUid))
        .toList();
  }

  /// Offer help page, tab 2 (Ongoing request)
  static Future<List<ServiceRequest>> getMyOngoingServices() async {
    var userUid = FirebaseAuth.instance.currentUser!.uid;

    var snapshot = await FirebaseFirestore.instance
        .collection('serviceRequests')
        .where('requestorId', isNotEqualTo: userUid)
        .where('status', whereIn: [
          ServiceRequestStatus.pending.name,
          ServiceRequestStatus.accepted.name,
          ServiceRequestStatus.ongoing.name
        ])
        .where('applicants', arrayContains: userUid)
        .get();

    var snapshotData = snapshot.docs;

    return snapshotData.map((e) {
      var serviceRequest = ServiceRequest.fromJson(e.data());
      serviceRequest.id = e.id;
      return serviceRequest;
    }).toList();
  }

  /// Get the completed request (Offer help page, 3rd tab)
  static Future<List<ServiceRequest>> getCompletedServices() async {
    var userUid = FirebaseAuth.instance.currentUser!.uid;

    var dataDocs = await FirebaseFirestore.instance
        .collection('serviceRequests')
        .where('requestorId', isNotEqualTo: userUid)
        .where('providerId', isEqualTo: userUid)
        .where(
      'status',
      whereIn: [
        ServiceRequestStatus.completed.name,
        ServiceRequestStatus.completedVerified.name
      ],
    ).get();

    return dataDocs.docs.map((e) {
      var serviceRequest = ServiceRequest.fromJson(e.data());
      serviceRequest.id = e.id;
      return serviceRequest;
    }).toList();
  }

  static Future<void> applyApplicant(String serviceId, String applicantId) {
    return FirebaseFirestore.instance
        .collection('serviceRequests')
        .doc(serviceId)
        .update({
      'applicants': FieldValue.arrayUnion([applicantId])
    });
  }

  /// Accept an applicant (triggered from the offer help page)
  static Future<void> applyProvider(String serviceId, String providerId) {
    return FirebaseFirestore.instance
        .collection('serviceRequests')
        .doc(serviceId)
        .update({
      'providerId': providerId,
      'status': ServiceRequestStatus.accepted.name
    });
  }

  /// Get service details by job id
  static Future<ServiceRequest> getServiceRequestById(String jobId) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('serviceRequests')
        .doc(jobId)
        .get();

    if (!snapshot.exists) throw Exception("Service Request $jobId not exist");
    var serviceRequest = ServiceRequest.fromJson(snapshot.data()!);
    serviceRequest.id = snapshot.id;
    return serviceRequest;
  }
}
