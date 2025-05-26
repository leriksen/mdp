module "globals" {
  source = "../globals"
}

locals {
  as_string = {
    NP = "Non-Production"
    P  = "Production"
  }

  purpose = {
    NP = "non-prd"
    P  = "prd"
  }

  id = {
    NP = "2884ad0b-0ac1-4f07-a315-cba72baeec5a"
    P  = "40290e59-ccc4-4e54-ad38-c5461a690846"
  }
}
