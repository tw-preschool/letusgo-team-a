rm ./db/*.sqlite3

RACK_ENV=development rake migrate
RACK_ENV=test rake migrate

rake seed
