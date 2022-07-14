import logging

import azure.functions as func


def main(myblob: func.InputStream):
    logging.info(f"Python blob trigger function processed blob \n"
                 f"Name new code: {myblob.name}\n"
                 f"Blob Size: {myblob.length} bytes")
