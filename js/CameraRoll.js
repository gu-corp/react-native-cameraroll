/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @flow
 * @format
 */
'use strict';

const invariant = require('fbjs/lib/invariant');
const {NativeModules, Platform} = require('react-native');

const RNCCameraRoll = NativeModules.RNCCameraRoll;

const GROUP_TYPES_OPTIONS = {
  Album: 'Album',
  All: 'All', // default
  Event: 'Event',
  Faces: 'Faces',
  Library: 'Library',
  PhotoStream: 'PhotoStream',
  SavedPhotos: 'SavedPhotos',
};

const ASSET_TYPE_OPTIONS = {
  All: 'All',
  Videos: 'Videos',
  Photos: 'Photos',
};

export type GroupTypes = $Keys<typeof GROUP_TYPES_OPTIONS>;

export type Include =
  | 'filename'
  | 'fileSize'
  | 'location'
  | 'imageSize'
  | 'playableDuration';

export type GetPhotosParams = {
  first: number,
  after?: string,
  groupTypes?: GroupTypes,
  groupName?: string,
  assetType?: $Keys<typeof ASSET_TYPE_OPTIONS>,
  fromTime?: number,
  toTime?: Number,
  mimeTypes?: Array<string>,
  include?: Include[],
};

export type PhotoIdentifier = {
  node: {
    type: string,
    group_name: string,
    image: {
      filename: string | null,
      uri: string,
      height: number,
      width: number,
      fileSize: number | null,
      playableDuration: number,
    },
    timestamp: number,
    location: {
      latitude?: number,
      longitude?: number,
      altitude?: number,
      heading?: number,
      speed?: number,
    } | null,
  },
};

export type PhotoIdentifiersPage = {
  edges: Array<PhotoIdentifier>,
  page_info: {
    has_next_page: boolean,
    start_cursor?: string,
    end_cursor?: string,
  },
  limited?: boolean,
};

export type SaveToCameraRollOptions = {
  type?: 'photo' | 'video' | 'auto',
  album?: string,
};

export type GetAlbumsParams = {
  assetType?: $Keys<typeof ASSET_TYPE_OPTIONS>,
};

export type Album = {
  title: string,
  count: number,
};

/**
 * `CameraRoll` provides access to the local camera roll or photo library.
 *
 * See https://facebook.github.io/react-native/docs/cameraroll.html
 */
class CameraRoll {
  static GroupTypesOptions = GROUP_TYPES_OPTIONS;
  static AssetTypeOptions = ASSET_TYPE_OPTIONS;

  /**
   * Saves the photo to the camera roll using UIImageWriteToSavedPhotosAlbum (iOS only)
   * This method doesn't require NSPhotoLibraryUsageDescription
   */
  static saveToLibrary(tag: string): Promise<string> {
    invariant(
      typeof tag === 'string',
      'CameraRoll.saveToLibrary must be a valid string.',
    );
    return RNCCameraRoll.saveToLibrary(tag);
  }

  /**
   * `CameraRoll.saveImageWithTag()` is deprecated. Use `CameraRoll.saveToLibrary()` instead.
   */
  static saveImageWithTag(tag: string): Promise<string> {
    console.warn(
      '`CameraRoll.saveImageWithTag()` is deprecated. Use `CameraRoll.saveToLibrary()` instead.',
    );
    return this.saveToLibrary(tag);
  }

  /**
   * Saves the photo or video to the camera roll or photo library.
   * @deprecated Use saveToLibrary instead for iOS compatibility
   */
  static save(
    tag: string,
    options: SaveToCameraRollOptions = {},
  ): Promise<string> {
    console.warn(
      'CameraRoll.save is deprecated. Use CameraRoll.saveToLibrary instead for iOS compatibility.',
    );
    return this.saveToLibrary(tag);
  }

  /**
   * @deprecated Use saveToLibrary instead for iOS compatibility
   */
  static saveToCameraRoll(
    tag: string,
    type?: 'photo' | 'video' | 'auto',
  ): Promise<string> {
    console.warn(
      'CameraRoll.saveToCameraRoll is deprecated. Use CameraRoll.saveToLibrary instead for iOS compatibility.',
    );
    return CameraRoll.saveToLibrary(tag);
  }

  /**
   * @deprecated Not available without NSPhotoLibraryUsageDescription on iOS
   */
  static getAlbums(
    params?: GetAlbumsParams = {assetType: ASSET_TYPE_OPTIONS.All},
  ): Promise<Album[]> {
    console.warn(
      'CameraRoll.getAlbums is not available without NSPhotoLibraryUsageDescription on iOS',
    );
    if (Platform.OS === 'ios') {
      return Promise.reject(new Error('Photo library access is not available in this app configuration'));
    }
    return RNCCameraRoll.getAlbums(params);
  }

  /**
   * @deprecated Not available without NSPhotoLibraryUsageDescription on iOS
   */
  static getPhotos(params: GetPhotosParams): Promise<PhotoIdentifiersPage> {
    console.warn(
      'CameraRoll.getPhotos is not available without NSPhotoLibraryUsageDescription on iOS',
    );
    if (Platform.OS === 'ios') {
      return Promise.reject(new Error('Photo library access is not available in this app configuration'));
    }
    
    const newParams = {...params};
    if (!newParams.assetType) {
      newParams.assetType = ASSET_TYPE_OPTIONS.All;
    }
    if (!newParams.groupTypes && Platform.OS !== 'android') {
      newParams.groupTypes = GROUP_TYPES_OPTIONS.All;
    }

    const promise = RNCCameraRoll.getPhotos(newParams);

    if (arguments.length > 1) {
      console.warn(
        'CameraRoll.getPhotos(tag, success, error) is deprecated. Use the returned Promise instead',
      );
      let successCallback = arguments[1];
      const errorCallback = arguments[2] || (() => {});
      promise.then(successCallback, errorCallback);
    }

    return promise;
  }

  /**
   * @deprecated Not available without NSPhotoLibraryUsageDescription on iOS
   */
  static deletePhotos(photoUris: Array<string>): Promise<boolean> {
    console.warn(
      'CameraRoll.deletePhotos is not available without NSPhotoLibraryUsageDescription on iOS',
    );
    if (Platform.OS === 'ios') {
      return Promise.reject(new Error('Photo library access is not available in this app configuration'));
    }
    return RNCCameraRoll.deletePhotos(photoUris);
  }
}

module.exports = CameraRoll;