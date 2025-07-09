#!/bin/bash
set -e

host="$1"
shift
cmd="$@"

until pg_isready -h "$host" -p 5432; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - executing command"
exec $cmd

echo "Postgres is ready"


echo "testing the CD"

echo "Hiiii"

echo "3rd test"



echo "3.14"

echo "runner"

echo "3.33"

echo "3.27"
echo "3.14"

