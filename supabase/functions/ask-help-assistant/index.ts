// supabase/functions/ask-help-assistant/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  const { query } = await req.json();

  // 1. Generate an embedding for the user's question
  // (Using a standard embedding model API here)
  const embeddingResponse = await fetch('https://api.openai.com/v1/embeddings', {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ input: query, model: 'text-embedding-ada-002' })
  });
  const embeddingData = await embeddingResponse.json();
  const queryEmbedding = embeddingData.data[0].embedding;

  // 2. Search your database for the most relevant documentation
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
  const { data: documents } = await supabase.rpc('match_documents', {
    query_embedding: queryEmbedding,
    match_threshold: 0.78, // Only return highly relevant documents
    match_count: 3
  });

  const contextText = documents?.map(doc => doc.content).join('\n') || 'No specific documentation found.';

  // 3. Ask the LLM to answer the question using ONLY the provided documentation
  const geminiApiKey = Deno.env.get('GEMINI_API_KEY');
  const aiResponse = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-pro:generateContent?key=${geminiApiKey}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [{
        parts: [{
          text: `You are a helpful software support assistant for a facility mapping app. 
          Use the following internal documentation to answer the user's question. If the answer is not in the documentation, say "I cannot find the answer in the current documentation."
          
          Documentation:
          ${contextText}
          
          User Question:
          ${query}`
        }]
      }]
    })
  });

  const aiData = await aiResponse.json();
  const answer = aiData.candidates[0].content.parts[0].text;

  // Return the answer to the Flutter app
  return new Response(JSON.stringify({ answer }), { headers: { "Content-Type": "application/json" } });
});