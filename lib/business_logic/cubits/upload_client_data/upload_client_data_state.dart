import 'dart:io';

abstract class UploadClientDataState {}

class UploadClientDataInitial extends UploadClientDataState {}

class ImageLoading extends UploadClientDataState {}

class ImageLoaded extends UploadClientDataState {
  final File image;

  ImageLoaded(this.image);
}

class ImageError extends UploadClientDataState {
  final String message;

  ImageError(this.message);
}

class UploadClientDataloading extends UploadClientDataState {}

class UploadClientDataloaded extends UploadClientDataState {}

class UploadClientDataError extends UploadClientDataState {
  final String message;

  UploadClientDataError(this.message);
}
