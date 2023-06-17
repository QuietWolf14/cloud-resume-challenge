resource "aws_dynamodb_table" "CRC_Resume_Attr_table" {
  name           = "CRC_Resume_Attr"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "WebpageAttr"

  attribute {
    name = "WebpageAttr"
    type = "S"
  }

  /* ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  } */

  tags = {
    Name        = "CRC-visitor-count"
    Environment = "dev"
  }
}

resource "aws_dynamodb_table_item" "CRC_Resume_Attr_table_item" {
  table_name = aws_dynamodb_table.CRC_Resume_Attr_table.name
  hash_key   = aws_dynamodb_table.CRC_Resume_Attr_table.hash_key

  item = <<ITEM
{
  "WebpageAttr": {"S": "VisitorCount"},
  "AttrValue": {"S": "0"}
}
ITEM
}

