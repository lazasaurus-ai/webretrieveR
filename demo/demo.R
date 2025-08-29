devtools::load_all()
webretrieveR::wr_list_engines()
# Expect: "ddg" "wikipedia"

# Smoke Test 
cat(webretrieveR::wr_retrieve("R programming language", engines = "ddg"), "\n\n")
cat(webretrieveR::wr_retrieve("R programming language", engines = "wikipedia"), "\n\n")

# Combined Engines
ctx <- webretrieveR::wr_retrieve("Posit Workbench", engines = c("ddg","wikipedia"))
cat(substr(ctx, 1, 800))  # preview first 800 chars
