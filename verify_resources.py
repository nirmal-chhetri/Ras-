import os
import json
import urllib.request
import urllib.error

def audit():
    print("=== AETHER SENSORY COMMERCE: RESOURCE AUDIT ===")
    
    with open("DATA_CATALOG.json", "r", encoding="utf-8") as f:
        data = json.load(f)

    specimens = data.get("specimens", [])
    print(f"\n[1] Auditing Visual Resources ({len(specimens)} Unsplash CDN Assets):")
    
    success_images = 0
    headers = {"User-Agent": "Mozilla/5.0"}

    for s in specimens:
        url = s.get("imageUrl")
        item_id = s.get("id")
        title = s.get("title")
        try:
            req = urllib.request.Request(url, headers=headers, method="HEAD")
            with urllib.request.urlopen(req, timeout=10) as res:
                content_type = res.headers.get("Content-Type", "")
                content_len = res.headers.get("Content-Length", "unknown")
                print(f"  [OK 200] {item_id}: {title[:30]:30} | {content_type} | {content_len} bytes")
                success_images += 1
        except Exception as e:
            print(f"  [FAIL]   {item_id}: {title[:30]:30} | Error: {e}")

    print(f"\nVisual Assets Reachable: {success_images}/{len(specimens)}")

    print(f"\n[2] Auditing Artisan Provenance URLs:")
    success_prov = 0
    for s in specimens:
        url = s.get("provenanceUrl")
        maker = s.get("maker")
        try:
            req = urllib.request.Request(url, headers=headers, method="HEAD")
            with urllib.request.urlopen(req, timeout=10) as res:
                print(f"  [OK {res.status}] {maker:25} -> {url}")
                success_prov += 1
        except Exception as e:
            # Some sites block HEAD requests with 403 or 405, fallback to GET with small read
            try:
                req = urllib.request.Request(url, headers=headers, method="GET")
                with urllib.request.urlopen(req, timeout=10) as res:
                    print(f"  [OK {res.status}] {maker:25} -> {url}")
                    success_prov += 1
            except Exception as e2:
                print(f"  [WARN] {maker:25} -> {url} ({e2})")

    print(f"\nProvenance Links Reachable: {success_prov}/{len(specimens)}")

    print("\n[3] Auditing Typography Dependencies:")
    fonts = [
        "https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;1,400&display=swap",
        "https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap",
        "https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;700&display=swap"
    ]
    for f_url in fonts:
        try:
            req = urllib.request.Request(f_url, headers=headers)
            with urllib.request.urlopen(req, timeout=10) as res:
                print(f"  [OK 200] Font CDN Reachable: {f_url.split('=')[1].split('&')[0]}")
        except Exception as e:
            print(f"  [FAIL] Font CDN unreachable: {e}")

    print("\n[4] Audio Assets Readiness:")
    atmospheres = data.get("atmospheres", [])
    all_audio_ok = True
    for a in atmospheres:
        path = a.get("audioTrack")
        if os.path.exists(path):
            size_kb = os.path.getsize(path) / 1024
            print(f"  [OK BUNDLED {size_kb:.1f} KB] {a.get('id'):15} -> {path}")
        else:
            print(f"  [MISSING] {a.get('id'):15} -> {path}")
            all_audio_ok = False

    print("\n=== AUDIT COMPLETE ===")

if __name__ == "__main__":
    audit()
