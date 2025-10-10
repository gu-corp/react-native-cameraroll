/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

declare namespace CameraRoll {
  type GroupType =
    | 'Album'
    | 'All'
    | 'Event'
    | 'Faces'
    | 'Library'
    | 'PhotoStream'
    | 'SavedPhotos';

  type AssetType = 'All' | 'Videos' | 'Photos';

  type Include =
    /** Ensures the filename is included. Has a large performance hit on iOS */
    | 'filename'
    /** Ensures the fileSize is included. Has a large performance hit on iOS */
    | 'fileSize'
    /** Ensures the location is included. Has a medium performance hit on Android */
    | 'location'
    /** Ensures the image width and height are included. Has a small performance hit on Android */
    | 'imageSize'
    /** Ensures the image playableDuration is included. Has a medium performance hit on Android */
    | 'playableDuration';

  interface GetPhotosParams {
    first: number;
    after?: string;
    groupTypes?: GroupType;
    groupName?: string;
    assetType?: AssetType;
    fromTime?: number;
    toTime?: number;
    mimeTypes?: Array<string>;
    include?: Include[];
  }

  interface PhotoIdentifier {
    node: {
      type: string;
      group_name: string;
      image: {
        filename: string | null;
        uri: string;
        height: number;
        width: number;
        fileSize: number | null;
        playableDuration: number | null;
      };
      timestamp: number;
      location: {
        latitude?: number;
        longitude?: number;
        altitude?: number;
        heading?: number;
        speed?: number;
      } | null;
    };
  }

  interface PhotoIdentifiersPage {
    edges: Array<PhotoIdentifier>;
    page_info: {
      has_next_page: boolean;
      start_cursor?: string;
      end_cursor?: string;
    };
  }

  interface GetAlbumsParams {
    assetType?: AssetType;
  }

  interface Album {
    title: string;
    count: number;
  }

  type SaveToCameraRollOptions = {
    type?: 'photo' | 'video' | 'auto';
    album?: string;
  };

  /**
   * Saves the photo to the camera roll using UIImageWriteToSavedPhotosAlbum (iOS only)
   * This method doesn't require NSPhotoLibraryUsageDescription
   */
  function saveToLibrary(tag: string): Promise<string>;

  /**
   * @deprecated Use saveToLibrary instead for iOS compatibility
   */
  function saveToCameraRoll(
    tag: string,
    type?: 'photo' | 'video',
  ): Promise<string>;

  /**
   * @deprecated Use saveToLibrary instead for iOS compatibility
   */
  function save(
    tag: string,
    options?: SaveToCameraRollOptions,
  ): Promise<string>;

  /**
   * @deprecated Not available without NSPhotoLibraryUsageDescription on iOS
   */
  function getPhotos(params: GetPhotosParams): Promise<PhotoIdentifiersPage>;

  /**
   * @deprecated Not available without NSPhotoLibraryUsageDescription on iOS
   */
  function getAlbums(params: GetAlbumsParams): Promise<Album[]>;

  /**
   * @deprecated Not available without NSPhotoLibraryUsageDescription on iOS
   */
  function deletePhotos(photoUris: Array<string>): Promise<boolean>;
}

export = CameraRoll;
