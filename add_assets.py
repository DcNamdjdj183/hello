import os
import shutil
import json

upload_dir = r"C:/Users/Administrator/.gemini/antigravity/brain/2d838db2-8599-4769-a951-8d7a2111013f/.user_uploaded"
assets_dir = r"ThreeOneOSFive/Assets.xcassets"

images = {
    "icon_pubg": "media_1789313470580.png",
    "icon_capcut": "media_1789313475222.png",
    "icon_ffmax": "media_1789313480008.png",
    "icon_ffth": "media_1789313484069.png",
    "icon_lq": "media_1789313487409.png"
}

for name, filename in images.items():
    src_path = os.path.join(upload_dir, filename)
    
    # Create .imageset folder
    imageset_dir = os.path.join(assets_dir, f"{name}.imageset")
    os.makedirs(imageset_dir, exist_ok=True)
    
    # Copy file
    dest_path = os.path.join(imageset_dir, filename)
    if os.path.exists(src_path):
        shutil.copy(src_path, dest_path)
    
        # Write Contents.json
        contents = {
            "images": [
                {
                    "filename": filename,
                    "idiom": "universal",
                    "scale": "1x"
                },
                {
                    "idiom": "universal",
                    "scale": "2x"
                },
                {
                    "idiom": "universal",
                    "scale": "3x"
                }
            ],
            "info": {
                "author": "xcode",
                "version": 1
            }
        }
        
        with open(os.path.join(imageset_dir, "Contents.json"), "w") as f:
            json.dump(contents, f, indent=2)
        print(f"Added {name}")
    else:
        print(f"Not found: {src_path}")
