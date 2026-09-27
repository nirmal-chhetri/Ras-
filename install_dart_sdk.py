import urllib.request
import zipfile
import os
import shutil

def download_and_extract():
    url = "https://storage.googleapis.com/flutter_infra_release/flutter/af7e796e161ae0bb1ff0758c71a7105418bd9ded/dart-sdk-windows-x64.zip"
    cache_dir = r"C:\src\flutter\bin\cache"
    zip_path = os.path.join(cache_dir, "dart-sdk-windows-x64.zip")
    lock_file = os.path.join(cache_dir, "flutter.bat.lock")
    
    if os.path.exists(lock_file):
        try:
            os.remove(lock_file)
            print("Removed flutter.bat.lock")
        except Exception as e:
            print("Lock file error:", e)

    print(f"Downloading Dart SDK from {url}...")
    headers = {"User-Agent": "Mozilla/5.0"}
    req = urllib.request.Request(url, headers=headers)
    
    with urllib.request.urlopen(req) as resp, open(zip_path, "wb") as out_file:
        total = int(resp.headers.get("Content-Length", 0))
        downloaded = 0
        block_size = 1024 * 1024  # 1MB
        while True:
            chunk = resp.read(block_size)
            if not chunk:
                break
            out_file.write(chunk)
            downloaded += len(chunk)
            if total > 0:
                percent = (downloaded / total) * 100
                print(f"Progress: {downloaded / 1024 / 1024:.1f} MB / {total / 1024 / 1024:.1f} MB ({percent:.1f}%)", end="\r")
    
    print("\nDownload complete. Extracting Dart SDK...")
    dart_sdk_dest = os.path.join(cache_dir, "dart-sdk")
    if os.path.exists(dart_sdk_dest):
        shutil.rmtree(dart_sdk_dest, ignore_errors=True)

    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(cache_dir)
    print("Dart SDK extracted successfully.")

    # Write engine-dart-sdk.stamp
    stamp_path = os.path.join(cache_dir, "engine-dart-sdk.stamp")
    with open(stamp_path, "w", encoding="utf-8") as f:
        f.write("af7e796e161ae0bb1ff0758c71a7105418bd9ded\n")
    print("Created engine-dart-sdk.stamp.")

if __name__ == "__main__":
    download_and_extract()
