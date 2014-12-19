export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

rm ./db/*.sqlite3

RACK_ENV=development rake migrate
RACK_ENV=test rake migrate

rake seed
