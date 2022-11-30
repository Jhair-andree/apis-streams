resource "aws_s3_bucket" "acme-storage-carlosfeu" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  bucket = var.bucket_name
  acl    = "private"
}
resource "aws_s3_object" "video_mas_20_mb" {
  bucket = aws_s3_bucket.acme-storage-carlosfeu.id
  key    = "gatitos.mp4"
  source = "gatitos.mp4"
  content_type = "mp4"
}