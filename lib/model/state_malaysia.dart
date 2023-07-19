/// Malaysia state and its districts model
class StateMalaysia {
  final String state;
  final List<String> districts;

  StateMalaysia({required this.state, required this.districts});

  @override
  String toString() => '$state: $districts';
}
