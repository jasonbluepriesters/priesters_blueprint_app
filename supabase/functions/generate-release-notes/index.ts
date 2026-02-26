// supabase/functions/generate-release-notes/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  // 1. Parse the incoming Webhook payload from Supabase
  const payload = await req.json();
  const newBlueprint = payload.record;
  const oldBlueprint = payload.old_record;

  // 2. Identify the differences (Simplified for example)
  // In a full production app, you would run a JSON diffing library here 
  // to pinpoint exactly which machines were added, moved, or deleted.
  const layoutDiff = JSON.stringify({
    previousMachineCount: oldBlueprint?.layoutElements?.length || 0,
    newMachineCount: newBlueprint.layoutElements.length,
    rawNewLayout: newBlueprint.layoutElements,
  });

  // 3. Call the AI Model (e.g., Google Gemini)
  const geminiApiKey = Deno.env.get('GEMINI_API_KEY');
  const aiResponse = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-pro:generateContent?key=${geminiApiKey}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [{
        parts: [{
          text: `You are a food safety compliance assistant. Analyze this facility layout data change and generate 3 concise, professional bullet points summarizing the modifications for an audit log. Do not invent details. Layout Data: ${layoutDiff}`
        }]
      }]
    })
  });

  const aiData = await aiResponse.json();
  const generatedBulletPoints = aiData.candidates[0].content.parts[0].text;

  // 4. Save the AI-generated notes back to your Supabase Database
  const supabaseAdmin = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  );

  await supabaseAdmin.from('blueprint_version_history').insert({
    blueprint_id: newBlueprint.id,
    version_number: newBlueprint.versionNumber,
    release_notes: generatedBulletPoints,
    created_at: new Date().toISOString(),
  });

  return new Response(JSON.stringify({ success: true }), { 
    headers: { "Content-Type": "application/json" } 
  });
});