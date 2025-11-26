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

    def _get_clinic_tables(self, clinic_id: str) -> Dict[str, str]:
        """Get clinic-specific table configuration"""
        return settings.get_clinic_config(clinic_id)

    async def chat_with_sop(self, clinic_id: str, user_query: str, language: str = "BM"):
        """RAG Search for Patients (FAQ/SOP) - Clinic Specific"""
        clinic_tables = self._get_clinic_tables(clinic_id)
        
        # Enhanced prompt to handle language preference
        system_message = f"""
        You are an AI assistant for {clinic_id} clinic. 
        Respond in {language} (BM for Bahasa Malaysia, EN for English).
        Provide accurate, clinic-specific information about:
        - Operating hours
        - Available services
        - Vaccine schedules
        - Treatment options
        - Pricing information
        
        Keep responses concise and helpful.
        """
        
        try:
            # Using the Chat/Completions endpoint with RAG enabled
            response = self.client.generate_chat_completions(
                messages=[
                    {"role": "system", "content": system_message},
                    {"role": "user", "content": user_query}
                ],
                # Use clinic-specific knowledge table
                knowledge_table_id=clinic_tables["knowledge_table_sop"],
                rag_k=3  # Fetch top 3 relevant chunks
            )
            return response.choices[0].message.content
        except Exception as e:
            logger.error(f"Error in chat_with_sop for clinic {clinic_id}: {str(e)}")
            fallback_message = "Maaf, sistem sedang menghadapi masalah teknikal." if language == "BM" else "Sorry, the system is experiencing technical issues."
            return fallback_message

    async def chat_with_faqs(self, clinic_id: str, user_query: str, language: str = "BM"):
        """RAG Search for clinic-specific FAQs"""
        clinic_tables = self._get_clinic_tables(clinic_id)
        
        system_message = f"""
        You are an FAQ assistant for {clinic_id} clinic.
        Answer common patient questions in {language}.
        Be helpful, accurate, and clinic-specific.
        """
        
        try:
            response = self.client.generate_chat_completions(
                messages=[
                    {"role": "system", "content": system_message},
                    {"role": "user", "content": user_query}
                ],
                knowledge_table_id=clinic_tables["knowledge_table_faqs"],
                rag_k=5
            )
            return response.choices[0].message.content
        except Exception as e:
            logger.error(f"Error in chat_with_faqs for clinic {clinic_id}: {str(e)}")
            fallback_message = "Maaf, tidak dapat menjawab soalan FAQ ini." if language == "BM" else "Sorry, cannot answer this FAQ question."
            return fallback_message

    async def appointment_booking(self, clinic_id: str, clinic_name: str, user_input: str, language: str = "BM"):
        """
        A. Appointment Booking Action Table
        Strict Input: user_input (str), clinic_name (str)
        Strict Output: refined_user_message (str), booking_record (str json format)
        """
        try:
            # Prepare input data exactly as specified
            input_data = {
                "user_input": user_input,
                "clinic_name": clinic_name
            }
            
            # Add row to Appointment Booking Action Table (shared across clinics)
            completion = self.client.table.add_table_rows(
                table_type=p.TableType.ACTION,
                request=p.RowAddRequest(
                    table_id=settings.ACTION_TABLE_TRIAGE,  # "Appointment Booking"
                    data=[input_data],
                    stream=False
                )
            )
            
            # Extract outputs according to strict format
            if completion.rows and len(completion.rows) > 0:
                row = completion.rows[0]
                
                # Get refined_user_message and booking_record outputs
                refined_message = row.columns.get("refined_user_message", {}).get("text", "")
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
            # Prepare input data exactly as specified
            input_data = {
                "question": question,
                "clinic_name": clinic_name
            }
            
            # Add row to SOP QnA Action Table (shared across clinics)
            completion = self.client.table.add_table_rows(
                table_type=p.TableType.ACTION,
                request=p.RowAddRequest(
                    table_id=settings.ACTION_TABLE_SOP_QNA,  # "SOP QnA"
                    data=[input_data],
                    stream=False
                )
            )
            
            # Extract outputs according to strict format
            if completion.rows and len(completion.rows) > 0:
                row = completion.rows[0]
                
                # Get response and source_document outputs
                response = row.columns.get("response", {}).get("text", "")
                source_document = row.columns.get("source_document", {}).get("text", "")
                
                return {
                    "response": response,
                    "source_document": source_document
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
            # Prepare input data exactly as specified
            input_data = {
                "user_input": user_input,
                "clinic_name": clinic_name
            }
            
            # Add row to Medical Lookup Action Table (shared across clinics)
            completion = self.client.table.add_table_rows(
                table_type=p.TableType.ACTION,
                request=p.RowAddRequest(
                    table_id=settings.ACTION_TABLE_LOOKUP,  # "Medical Lookup"
                    data=[input_data],
                    stream=False
                )
            )
            
            # Extract outputs according to strict format
            if completion.rows and len(completion.rows) > 0:
                row = completion.rows[0]
                
                # Get drug_entry and medication_message outputs
                drug_entry = row.columns.get("drug_entry", {}).get("text", "{}")
                medication_message = row.columns.get("medication_message", {}).get("text", "")
                
                return {
                    "drug_entry": drug_entry,
                    "medication_message": medication_message
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

    async def get_available_clinics(self) -> List[str]:
        """Get list of available clinic IDs"""
        return settings.get_all_clinic_ids()

jamai_service = JamAIService()