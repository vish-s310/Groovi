from app import create_app
app = create_app()
from flasgger import Swagger
Swagger(app)


if __name__ == '__main__':
    app.run(debug=True, port=5050)
