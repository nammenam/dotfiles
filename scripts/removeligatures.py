import sys
from pathlib import Path
from fontTools.ttLib import TTFont

def remove_ligatures(input_font_path, output_font_path):
    try:
        font = TTFont(input_font_path)

        if "GSUB" in font:
            gsub = font["GSUB"].table

            if hasattr(gsub, "FeatureList") and gsub.FeatureList:
                ligature_tags = ['liga', 'dlig', 'hlig', 'rlig']
                original_count = len(gsub.FeatureList.FeatureRecord)

                # Filter out the ligature feature records
                filtered_records = [
                    record for record in gsub.FeatureList.FeatureRecord
                    if record.FeatureTag not in ligature_tags
                ]

                # Apply the filtered list back to the font
                gsub.FeatureList.FeatureRecord = filtered_records
                gsub.FeatureList.FeatureCount = len(filtered_records)

                removed_count = original_count - len(filtered_records)
                print(f"  -> Removed {removed_count} ligature features.")
            else:
                print("  -> No FeatureList found in GSUB table.")
        else:
            print("  -> No GSUB table found. No ligatures to remove.")

        font.save(output_font_path)
        print(f"  -> Saved successfully.")

    except Exception as e:
        print(f"  -> Error processing font: {e}")

def main():
    # Check if correct number of arguments is provided
    if len(sys.argv) != 3:
        print("Usage: python remove_ligs.py <input_directory> <output_directory>")
        sys.exit(1)

    input_dir = Path(sys.argv[1])
    output_dir = Path(sys.argv[2])

    # Validate input directory
    if not input_dir.is_dir():
        print(f"Error: The input directory '{input_dir}' does not exist.")
        sys.exit(1)

    # Create output directory if it doesn't exist
    output_dir.mkdir(parents=True, exist_ok=True)

    # Find all .ttf and .otf files
    valid_extensions = {'.ttf', '.otf'}
    font_files = [f for f in input_dir.iterdir() if f.suffix.lower() in valid_extensions]

    if not font_files:
        print(f"No .ttf or .otf files found in '{input_dir}'.")
        sys.exit(0)

    print(f"Found {len(font_files)} font(s). Processing...")
    print("-" * 30)

    # Process each file
    for font_file in font_files:
        print(f"Processing: {font_file.name}")
        output_file = output_dir / font_file.name
        remove_ligatures(font_file, output_file)

if __name__ == "__main__":
    main()
