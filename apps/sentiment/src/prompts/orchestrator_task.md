Create a high-quality stock analysis report for {{COMPANY_NAME}} by following these steps:

1. Use the EvaluatorOptimizerLLM component (named 'research_quality_controller') to gather high-quality 
   financial data about {{COMPANY_NAME}}. This component will automatically evaluate 
   and improve the research until it reaches EXCELLENT quality.
   You can not directly use "search_finder" or "research_evaluator." 
   Instead, you must only use "research_quality_controller" as a single component to collect high-quality research.
   research_quality_controller automatically performs multiple iterations with the "search_finder" and "research_evaluator" to reach an EXCELLENT quality research result.
   
   Ask for:
   - Current stock price and recent movement
   - Latest quarterly earnings results and performance vs expectations
   - Recent news and developments
 
2. Use the financial_analyst agent to analyze this research data and identify key insights.

3. Use the report_writer agent to create a comprehensive stock report and save it to:
   "{{OUTPUT_PATH}}"

   Saving requirements:
   - The report_writer MUST call a filesystem write tool to write the JSON string to the exact path above.
   - The report_writer must then return the single line: `SAVED: {{OUTPUT_PATH}}`.
   - Consider the task incomplete until you detect the writer returned the `SAVED:` marker in the step result.
 
The final report should be professional, fact-based, and include all relevant financial information.
