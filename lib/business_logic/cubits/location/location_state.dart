class LocationState {
  final List<String> governorates;
  final List<String> cities;
  final List<String> neighborhoods;
  final String? selectedGovernorate;
  final String? selectedCity;
  final String? selectedNeighborhood;

  LocationState({
    this.governorates = const [],
    this.cities = const [],
    this.neighborhoods = const [],
    this.selectedGovernorate,
    this.selectedCity,
    this.selectedNeighborhood,
  });

  LocationState copyWith({
    List<String>? governorates,
    List<String>? cities,
    List<String>? neighborhoods,
    String? selectedGovernorate,
    String? selectedCity,
    String? selectedNeighborhood,
  }) {
    return LocationState(
      governorates: governorates ?? this.governorates,
      cities: cities ?? this.cities,
      neighborhoods: neighborhoods ?? this.neighborhoods,
      selectedGovernorate: selectedGovernorate ?? this.selectedGovernorate,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedNeighborhood: selectedNeighborhood ?? this.selectedNeighborhood,
    );
  }
}
