class LocationState {
  final List<String> governorates;
  final List<String> cities;
  final List<String> areas;
  final String? selectedGovernorate;
  final String? selectedCity;
  final String? selectedArea;

  LocationState({
    this.governorates = const [],
    this.cities = const [],
    this.areas = const [],
    this.selectedGovernorate,
    this.selectedCity,
    this.selectedArea,
  });

  LocationState copyWith({
    List<String>? governorates,
    List<String>? cities,
    List<String>? areas,
    String? selectedGovernorate,
    String? selectedCity,
    String? selectedArea,
  }) {
    return LocationState(
      governorates: governorates ?? this.governorates,
      cities: cities ?? this.cities,
      areas: areas ?? this.areas,
      selectedGovernorate: selectedGovernorate ?? this.selectedGovernorate,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedArea: selectedArea ?? this.selectedArea,
    );
  }
}
