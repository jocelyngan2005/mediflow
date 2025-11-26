from jamaibase import JamAI, protocol as p
from app.core.config import settings
from typing import Dict, List
import logging

logger = logging.getLogger(__name__)

class JamAIService:
    def __init__(self):
        self.client = JamAI(
            project_id=settings.JAMAI_PROJECT_ID, 
            token=settings.JAMAI_API_KEY
        )

    async def appointment_booking(self, clinic_id: str, clinic_name: str, user_input: str, language: str = "BM"):
        """
        A. Appointment Booking Action Table
        Strict Input: user_input (str), clinic_name (str)
        Strict Output: refined_user_message (str), booking_record (str json format)
        """
        try:
            # Add row to Action Table using the working pattern from test_action.py
            response = self.client.table.add_table_rows(
                table_type='action',
                request=p.RowAddRequest(
                    table_id=settings.ACTION_TABLE_TRIAGE,  # "Appointment Booking"
                    data=[{
                        "user_input": user_input,
                        "clinic_name": clinic_name
                    }],
                    stream=False
                )
            )
            
            # Extract outputs using direct column access like test_action.py
            if response.rows and len(response.rows) > 0:
                row = response.rows[0]
                
                # Access columns directly as in working test
                refined_message = row.columns["refined_user_message"].text
                booking_record = row.columns.get("booking_record", {}).get("text", "{}")
                
                return {
                    "refined_user_message": refined_message,
                    "booking_record": booking_record
                }
                        
            return {
                "refined_user_message": "Appointment request processed",
                "booking_record": "{}"
            }
            
        except Exception as e:
            logger.error(f"Error in appointment_booking for clinic {clinic_id}: {str(e)}")
            fallback_message = "Maaf, sistem tempahan menghadapi masalah." if language == "BM" else "Sorry, appointment booking system is experiencing issues."
            return {
                "refined_user_message": fallback_message,
                "booking_record": "{}"
            }

    async def pdf_sop_answering(self, clinic_id: str, clinic_name: str, question: str, language: str = "BM"):
        """
        B. SOP QnA Action Table
        Strict Input: question (str), clinic_name (str)
        Strict Output: response (str), source_document (str)
        """
        try:
            # Add row to Action Table using the working pattern from test_action.py
            response = self.client.table.add_table_rows(
                table_type='action',
                request=p.RowAddRequest(
                    table_id=settings.ACTION_TABLE_SOP_QNA,  # "SOP QnA"
                    data=[{
                        "question": question,
                        "clinic_name": clinic_name
                    }],
                    stream=False
                )
            )
            
            # Extract outputs using direct column access like test_action.py
            if response.rows and len(response.rows) > 0:
                row = response.rows[0]
                
                # Access columns directly as in working test
                ai_response = row.columns["response"].text
                source_doc = row.columns["source_doc"].text
                
                return {
                    "response": ai_response,
                    "source_document": source_doc
                }
                        
            return {
                "response": "No answer found in documents",
                "source_document": ""
            }
            
        except Exception as e:
            logger.error(f"Error in pdf_sop_answering for clinic {clinic_id}: {str(e)}")
            fallback_message = "Maaf, pencarian dokumen menghadapi masalah." if language == "BM" else "Sorry, document search is experiencing issues."
            return {
                "response": fallback_message,
                "source_document": ""
            }

    async def medication_lookup_staff(self, clinic_id: str, clinic_name: str, user_input: str):
        """
        C. Medical Lookup Action Table (Staff Only)
        Strict Input: user_input (str), clinic_name (str)
        Strict Output: drug_entry (str json format), medication_message (str)
        """
        try:
            # Add row to Action Table using the working pattern from test_action.py
            response = self.client.table.add_table_rows(
                table_type='action',
                request=p.RowAddRequest(
                    table_id=settings.ACTION_TABLE_LOOKUP,  # "Medical Lookup"
                    data=[{
                        "user_input": user_input,
                        "clinic_name": clinic_name
                    }],
                    stream=False
                )
            )
            
            # Extract outputs using direct column access like test_action.py
            if response.rows and len(response.rows) > 0:
                row = response.rows[0]
                
                # Access columns directly as in working test
                drug_data = row.columns["drug_entry"].text
                ai_message = row.columns["medication_message"].text
                
                return {
                    "drug_entry": drug_data,
                    "medication_message": ai_message
                }
                        
            return {
                "drug_entry": "{}",
                "medication_message": "No medication information found"
            }
            
        except Exception as e:
            logger.error(f"Error in medication_lookup_staff for clinic {clinic_id}: {str(e)}")
            return {
                "drug_entry": "{}",
                "medication_message": f"Error checking medication: {str(e)}"
            }

    # Legacy methods for backward compatibility
    async def triage_symptoms(self, clinic_id: str, symptom_text: str, patient_age: int = None, language: str = "BM"):
        """Legacy method - redirects to appointment booking"""
        # Get clinic name from clinic_id (you may want to implement a proper mapping)
        clinic_name = clinic_id.replace('-', ' ').title()
        user_input = f"Symptoms: {symptom_text}"
        if patient_age:
            user_input += f", Age: {patient_age}"
        result = await self.appointment_booking(clinic_id, clinic_name, user_input, language)
        # Return just the refined message for backward compatibility
        return result.get("refined_user_message", "Appointment processed")

    async def check_medication_stock(self, clinic_id: str, drug_name: str):
        """Legacy method - redirects to medication lookup"""
        clinic_name = clinic_id.replace('-', ' ').title()
        user_input = f"Check stock for {drug_name}"
        result = await self.medication_lookup_staff(clinic_id, clinic_name, user_input)
        # Return just the medication message for backward compatibility
        return result.get("medication_message", "Medication checked")

    async def pdf_qa(self, clinic_id: str, question: str, language: str = "BM"):
        """Legacy method - redirects to PDF/SOP answering"""
        clinic_name = clinic_id.replace('-', ' ').title()
        result = await self.pdf_sop_answering(clinic_id, clinic_name, question, language)
        # Return just the response for backward compatibility
        return result.get("response", "No answer found")



jamai_service = JamAIService()