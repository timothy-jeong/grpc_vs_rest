from starlette.applications import Starlette
from starlette.responses import JSONResponse
from starlette.routing import Route

async def rest_payload(request):
    size_param = request.query_params.get('size_in_kb')
    if size_param is None:
        size_param = 1
    
    try:
        size_in_kb  = int(size_param)
    except TypeError:
        size_in_kb = 1
    data = "x" * size_in_kb * 1024
    return JSONResponse({"data": data})

app = Starlette(debug=True, routes=[
    Route("/payload", rest_payload)
])