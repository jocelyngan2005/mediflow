# Script to test Action Tables manually 
import os
import sys
import asyncio
from dotenv import load_dotenv

# Load .env before importing other modules that depend on it
dotenv_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), '.env')
load_dotenv(dotenv_path=dotenv_path)

from jamaibase import JamAI, protocol as p

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from app.core.config import settings

async def test_triage_flow():
    jamai = JamAI(project_id=settings.JAMAI_PROJECT_ID, token=settings.JAMAI_API_KEY)
    
    # Simulate a patient scenario
    test_symptoms = "My child has had a high fever for 3 days and is vomiting."
    print(f"Testing Triage with symptoms: '{test_symptoms}'")

    try:
        # 1. Send data to Action Table
        print("... Sending to JamAI Action Table ...")
        response = jamai.table.add_table_rows(
            table_type='action',
            request=p.RowAddRequest(
                table_id=settings.ACTION_TABLE_TRIAGE,
                data=[{
                    "user_input": test_symptoms, # Ensure this matches your Input Column Name
                    "clinic_name": "Bandar Utama" 
                }],
                stream=False
            )
        )

        if response.rows:
            # 2. Fetch the output from the "AI Agent" column
            # Replace 'AI_Response' with whatever you named your output column
            ai_reply = response.rows[0].columns["refined_user_message"].text
            print("\nAI Nurse Response:")
            print("-" * 30)
            print(ai_reply)
            print("-" * 30)
        else:
            print("❌ No response received from Action Table.")

    except Exception as e:
        print(f"❌ Error: {e}")


async def test_chat_flow():
    jamai = JamAI(project_id=settings.JAMAI_PROJECT_ID, token=settings.JAMAI_API_KEY)
    
    # Simulate a patient scenario
    test_input = "Vaccines recommended for new born babies?"
    print(f"Testing Chat with question: '{test_input}'")

    try:
        # 1. Send data to Action Table
        print("... Sending to JamAI Action Table ...")
        response = jamai.table.add_table_rows(
            table_type='action',
            request=p.RowAddRequest(
                table_id=settings.ACTION_TABLE_SOP_QNA,
                data=[{
                    "question": test_input, # Ensure this matches your Input Column Name
                    "clinic_name": "Bandar Utama" 
                }],
                stream=False
            )
        )

        if response.rows:
            # 2. Fetch the output from the "AI Agent" column
            source = response.rows[0].columns["source_doc"].text
            ai_reply = response.rows[0].columns["response"].text
            print("\nResponse:")
            print("-" * 30)
            print(ai_reply)
            print("Source Document:")
            print(source)
            print("-" * 30)
        else:
            print("❌ No response received from Action Table.")

    except Exception as e:
        print(f"❌ Error: {e}")


async def test_lookup_flow():
    jamai = JamAI(project_id=settings.JAMAI_PROJECT_ID, token=settings.JAMAI_API_KEY)
    
    # Simulate a patient scenario
    test_search = "Allergy cream"
    print(f"Testing Lookup with question: '{test_search}'")

    try:
        # 1. Send data to Action Table
        print("... Sending to JamAI Action Table ...")
        response = jamai.table.add_table_rows(
            table_type='action',
            request=p.RowAddRequest(
                table_id=settings.ACTION_TABLE_LOOKUP,
                data=[{
                    "user_input": test_search, # Ensure this matches your Input Column Name
                    "clinic_name": "Bandar Utama" 
                }],
                stream=False
            )
        )

        if response.rows:
            # 2. Fetch the output from the "AI Agent" column
            drug_data = response.rows[0].columns["drug_entry"].text
            ai_reply = response.rows[0].columns["medication_message"].text
            print("\nDrug Data:")
            print("-" * 30)
            print(drug_data)
            print("AI Response:")
            print(ai_reply)
            print("-" * 30)
        else:
            print("❌ No response received from Action Table.")

    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(test_lookup_flow())