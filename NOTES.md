# Notes

Autoreplace in multiple queries:

    find . -type f -name '*.rq' | xargs sed -i 's|old|new|g'
