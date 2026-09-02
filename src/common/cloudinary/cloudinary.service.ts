import { Injectable, InternalServerErrorException, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { v2 as cloudinary } from 'cloudinary';

export interface CloudinaryUploadResult {
  url: string;
  publicId: string;
}

/// Thin wrapper around the Cloudinary SDK: uploads product photos and
/// cleans up replaced/removed ones. Credentials only ever live here
/// (server-side env vars) - the client sends the compressed image as
/// base64 and never talks to Cloudinary directly.
@Injectable()
export class CloudinaryService implements OnModuleInit {
  constructor(private readonly configService: ConfigService) {}

  onModuleInit() {
    cloudinary.config({
      cloud_name: this.configService.get<string>('cloudinary.cloudName'),
      api_key: this.configService.get<string>('cloudinary.apiKey'),
      api_secret: this.configService.get<string>('cloudinary.apiSecret'),
    });
  }

  private assertConfigured() {
    const { cloud_name, api_key, api_secret } = cloudinary.config();
    if (!cloud_name || !api_key || !api_secret) {
      throw new InternalServerErrorException(
        'Cloudinary no está configurado (faltan CLOUDINARY_CLOUD_NAME/API_KEY/API_SECRET)',
      );
    }
  }

  /// Uploads an already-compressed image (base64, no "data:" prefix,
  /// produced client-side as JPEG) and returns its public URL + id.
  async uploadBase64(
    base64Jpeg: string,
    folder = 'la-bomba/vegetables',
  ): Promise<CloudinaryUploadResult> {
    this.assertConfigured();

    try {
      const result = await cloudinary.uploader.upload(`data:image/jpeg;base64,${base64Jpeg}`, {
        folder,
        resource_type: 'image',
      });
      return { url: result.secure_url, publicId: result.public_id };
    } catch (error) {
      throw new InternalServerErrorException(
        `No se pudo subir la imagen a Cloudinary: ${error?.message || error}`,
      );
    }
  }

  /// Best-effort delete - swallows errors so a failed cleanup (e.g. the
  /// image was already removed) never blocks the actual operation
  /// (replacing/removing a product's photo).
  async deleteImage(publicId: string): Promise<void> {
    if (!publicId) return;
    try {
      await cloudinary.uploader.destroy(publicId);
    } catch {
      // Not worth failing the request over a cleanup that didn't happen.
    }
  }
}
