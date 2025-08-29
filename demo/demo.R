devtools::load_all()
webretrieveR::wr_list_engines()
# Expect: "ddg" "wikipedia"

# Smoke Test 
cat(webretrieveR::wr_retrieve("R programming language", engines = "ddg"), "\n\n")
cat(webretrieveR::wr_retrieve("R programming language", engines = "wikipedia"), "\n\n")

# Combined Engines
ctx <- webretrieveR::wr_retrieve("Posit Workbench", engines = c("ddg","wikipedia"))
cat(substr(ctx, 1, 800))  # preview first 800 chars


# Simple pass as context to ellmer
# ── 1) Load ellmer ─────────────────────────────────────────────
library(ellmer)

# ── 2) Pretend wr_retrieve gives us text from DuckDuckGo ───────
# (replace this with your real function call)
context <- webretrieveR::wr_retrieve("R Package Tidymodels", engines = "ddg")
print(context)
# ── 3) Create ellmer client ────────────────────────────────────
chat <- ellmer::chat_aws_bedrock(
  model = "anthropic.claude-3-5-sonnet-20240620-v1:0"
)

# ── 4) Ask a question, passing context straight in ─────────────
response <- chat$chat(paste0(
  "Use the following context when answering:\n\n",
  context, "\n\n",
  "Question: Tell me about tidymodels"
))

cat(response)
