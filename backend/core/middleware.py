import logging
import traceback

class LoggingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
        self.logger = logging.getLogger('django.request')

    def __call__(self, request):
        return self.get_response(request)

    def process_exception(self, request, exception):
        with open('debug_error.log', 'a') as f:
            f.write(f"\n--- Exception for {request.path} ---\n")
            f.write(traceback.format_exc())
            f.write("\n")
        return None
