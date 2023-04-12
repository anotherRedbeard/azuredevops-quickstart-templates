import logging
import os

import azure.functions as func


def main(req: func.HttpRequest) -> func.HttpResponse:
    env_setting = os.environ['EnvSetting']
    logging.info(f'Python HTTP trigger function processed a request for {env_setting} environment.')

    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    if name:
        return func.HttpResponse(f"Hello there, {name}. This HTTP triggered function executed successfully in {env_setting} env.")
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
             status_code=200
        )
