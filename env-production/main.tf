# production.tf

data "aws_acm_certificate" "webapi" {
  domain   = "fitnesskeeperapi.com"
  statuses = ["ISSUED"]
}

resource "aws_api_gateway_rest_api" "webapi" {
  name        = "webapi"
  description = "Production API Gateway for webapi"

  binary_media_types = [
    "*/*",
    "application/gzip",
    "text/plain",
  ]
}

resource "aws_api_gateway_stage" "prod" {
  rest_api_id           = "${aws_api_gateway_rest_api.webapi.id}"
  stage_name            = "prod"
  deployment_id         = "${aws_api_gateway_deployment.prod.id}"
  cache_cluster_enabled = false
}

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id       = "${aws_api_gateway_rest_api.webapi.id}"
  description       = "Deployment of webapi prod"
  stage_name        = "prod"
  stage_description = "Prod stage for webapi"

  depends_on = ["aws_api_gateway_integration.proxy-any"]
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.webapi.id}"
  parent_id   = "${aws_api_gateway_rest_api.webapi.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy-any" {
  rest_api_id      = "${aws_api_gateway_rest_api.webapi.id}"
  resource_id      = "${aws_api_gateway_resource.proxy.id}"
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = false

  request_parameters {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method_settings" "proxy-any" {
  rest_api_id = "${aws_api_gateway_rest_api.webapi.id}"
  stage_name  = "${aws_api_gateway_stage.prod.stage_name}"
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    logging_level      = "ERROR"
    data_trace_enabled = false
    caching_enabled    = false
  }
}

resource "aws_api_gateway_integration" "proxy-any" {
  rest_api_id             = "${aws_api_gateway_rest_api.webapi.id}"
  resource_id             = "${aws_api_gateway_resource.proxy.id}"
  http_method             = "${aws_api_gateway_method.proxy-any.http_method}"
  integration_http_method = "${aws_api_gateway_method.proxy-any.http_method}"
  type                    = "HTTP_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  uri                     = "https://lb.fitnesskeeperapi.com/{proxy}"

  request_parameters {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_domain_name" "webapi" {
  domain_name     = "fitnesskeeperapi.com"
  certificate_arn = "${data.aws_acm_certificate.webapi.arn}"
}

resource "aws_api_gateway_base_path_mapping" "webapi" {
  api_id      = "${aws_api_gateway_rest_api.webapi.id}"
  domain_name = "${aws_api_gateway_domain_name.webapi.domain_name}"
  stage_name  = "${aws_api_gateway_stage.prod.stage_name}"
}
