# Script to upload PDF/CSV to JamAI 

import os
import sys
from dotenv import load_dotenv
from jamaibase import JamAI, protocol as p

# Add the parent directory to sys.path to import config
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from app.core.config import settings

load_dotenv()

def upload_data():
    jamai = JamAI(project_id=settings.JAMAI_PROJECT_ID, token=settings.JAMAI_API_KEY)
    
    data_dir = "data"
    if not os.path.exists(data_dir):
        print(f"Directory '{data_dir}' not found. Please create it and add your PDFs/CSVs.")
        return

    print("Starting Batch Upload to JamAI Base...")

    for filename in os.listdir(data_dir):
        file_path = os.path.join(data_dir, filename)
        
        # Skip directories
        if not os.path.isfile(file_path):
            continue

        try:
            # 1. Upload PDFs to the SOP Knowledge Table
            if filename.lower().endswith(".pdf"):
                print(f"Uploading SOP: {filename}...")
                
                # In JamAI Base, we add a row with the file path
                # The system automatically parses and embeds the PDF
                jamai.table.add_table_rows(
                    table_type=p.TableType.KNOWLEDGE,
                    request=p.RowAddRequest(
                        table_id=settings.KNOWLEDGE_TABLE_SOP,
                        data=[{"file": file_path}], # Assumes column name is 'file' (standard)
                        stream=False
                    )
                )
                print(f"Indexed {filename}")

            # 2. Upload CSVs to the Medication Knowledge Table
            elif filename.lower().endswith(".csv"):
                print(f"Uploading Medication List: {filename}...")
                
                jamai.table.add_table_rows(
                    table_type=p.TableType.KNOWLEDGE,
                    request=p.RowAddRequest(
                        table_id=settings.KNOWLEDGE_TABLE_MEDS,
                        data=[{"file": file_path}],
                        stream=False
                    )
                )
                print(f"Indexed {filename}")

        except Exception as e:
            print(f"Failed to upload {filename}: {str(e)}")

    print("\nBatch Upload Complete!")

if __name__ == "__main__":
    upload_data()