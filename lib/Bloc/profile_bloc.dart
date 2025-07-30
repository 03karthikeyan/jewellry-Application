import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:jewellery/Event/profile_event.dart';
import 'package:jewellery/Model/profile_model.dart';
import 'package:jewellery/State/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<FetchProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final response = await http.get(
          Uri.parse(
            "https://pheonixconstructions.com/mobile/profileFetch.php?user_id=${event.userId}",
          ),
        );
        print("Response body: ${response.body}");

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          print("Parsed JSON: $data");

          if (data['result'] == 'Success') {
            final profile = Profile.fromJson(data);
            emit(ProfileLoaded(profile));
          } else {
            print('Invalid data structure received: $data');
            emit(
              ProfileError(
                "API Error: ${data['message'] ?? 'Failed to load profile'}",
              ),
            );
          }
        } else {
          emit(ProfileError("Network error"));
        }
      } catch (e) {
        emit(ProfileError("Something went wrong: $e"));
      }
    });
  }
}
