# Script to test Action Tables manually 

import os
import sys
import asyncio
from dotenv import load_dotenv
from jamaibase import JamAI, protocol as p

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from app.core.config import settings

load_dotenv()

async def test_triage_flow():
    jamai = JamAI(project_id=settings.JAMAI_PROJECT_ID, token=settings.JAMAI_API_KEY)
    
    # Simulate a patient scenario
    test_symptoms = "My child has had a high fever for 3 days and is vomiting."
    print(f"Testing Triage with symptoms: '{test_symptoms}'")

    try:
        # 1. Send data to Action Table
        print("... Sending to JamAI Action Table ...")
        response = jamai.table.add_table_rows(
            table_type=p.TableType.ACTION,
            request=p.RowAddRequest(
                table_id=settings.ACTION_TABLE_TRIAGE,
                data=[{
                    "User_Input": test_symptoms, # Ensure this matches your Input Column Name
                    "Language": "English"
                }],
                stream=False
            )
        )

        if response.rows:
            # 2. Fetch the output from the "AI Agent" column
            # Replace 'AI_Response' with whatever you named your output column
            ai_reply = response.rows[0].columns["AI_Response"].text
            print("\nAI Nurse Response:")
            print("-" * 30)
            print(ai_reply)
            print("-" * 30)
        else:
            print("❌ No response received from Action Table.")

    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(test_triage_flow())