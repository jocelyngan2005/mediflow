from jamaibase import JamAI, protocol as p
from app.core.config import settings

class JamAIService:
    def __init__(self):
        self.client = JamAI(
            project_id=settings.JAMAI_PROJECT_ID, 
            token=settings.JAMAI_API_KEY
        )

    async def chat_with_sop(self, user_query: str):
        """RAG Search for Patients (FAQ/SOP)"""
        # Using the Chat/Completions endpoint with RAG enabled
        response = self.client.generate_chat_completions(
            messages=[{"role": "user", "content": user_query}],
            # We instruct the model to use the Knowledge Table
            knowledge_table_id=settings.KNOWLEDGE_TABLE_SOP,
            rag_k=3  # Fetch top 3 relevant chunks
        )
        return response.choices[0].message.content

    async def triage_symptoms(self, symptom_text: str):
        """Push data to Action Table for Triage Logic"""
        # Add row to Action Table to trigger the pipeline
        completion = self.client.table.add_table_rows(
            table_type=p.TableType.ACTION,
            request=p.RowAddRequest(
                table_id=settings.ACTION_TABLE_TRIAGE,
                data=[{"symptoms": symptom_text}],
                stream=False
            )
        )
        # Return the Output Column from the Action Table (e.g., "AI_Response")
        return completion.rows[0].columns["AI_Response"].text

    async def check_medication_stock(self, drug_name: str):
        """
        Direct Query to Knowledge Table (CSV)
        Note: This is for STAFF only.
        """
        # We search the table directly to find the row
        results = self.client.table.embed_and_search(
            table_type=p.TableType.KNOWLEDGE,
            request=p.SearchRequest(
                table_id=settings.KNOWLEDGE_TABLE_MEDS,
                query=drug_name,
                k=1
            )
        )
        if not results.rows:
            return "Medication not found in stock list."
            
        # Assuming the CSV has columns: 'Drug', 'Stock', 'Price'
        row_data = results.rows[0]
        return f"Stock: {row_data['Stock']} units | Price: {row_data['Price']}"

jamai_service = JamAIService()