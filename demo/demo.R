install.packages(c("duckduckr","tibble")) # if needed
devtools::load_all(".")

hits <- search_web("What is ggplot2?")
print(hits)

# with ellmer (example)
library(ellmer)
chat <- ellmer::chat_aws_bedrock(
  model = "anthropic.claude-3-5-sonnet-20240620-v1:0",
  system_prompt = "Be concise. Use citations like [1], [2]."
)

wc <- WebClient$new(k_web = 3, chat_client = chat)
out <- wc$ask("What is ggplot2 and why use it?")
cat(out$answer)
out$citations
