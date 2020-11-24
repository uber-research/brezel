FROM python:3.6.10-slim-buster
RUN pip3 install click==7.1
RUN pip3 install cookiecutter==1.7
COPY entrypoint.py /cookiecutter-entrypoint.py

WORKDIR /project
ENTRYPOINT ["python", "/cookiecutter-entrypoint.py"]
CMD [""]
