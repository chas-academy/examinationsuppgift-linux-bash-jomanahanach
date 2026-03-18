#!/bin/bash
# create_users.sh
# Syfte: Skapar användare med hemkataloger, undermappar och välkomstfil.
# Användning: ./create_users.sh Anna Bjorn Charlie

# ─────────────────────────────────────────────
# 1. BEHÖRIGHETSKONTROLL – Endast root får köra
# ─────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
    echo "Fel: Du måste vara root för att köra detta script." >&2
    exit 1
fi

# Kontrollera att minst ett användarnamn skickades in
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 <användare1> [användare2] ..." >&2
    exit 1
fi

# ─────────────────────────────────────────────
# 2. SKAPA ANVÄNDARE OCH KATALOGER (första passet)
# ─────────────────────────────────────────────
# Vi sparar vilka användare som faktiskt skapades
SKAPADE=()

for ANVÄNDARE in "$@"; do

    # Kontrollera om användaren redan finns
    if id "$ANVÄNDARE" &>/dev/null; then
        echo "Varning: Användaren '$ANVÄNDARE' finns redan – hoppar över."
        continue
    fi

    # Skapa användaren med hemkatalog (-m) och bash som skal (-s)
    useradd -m -s /bin/bash "$ANVÄNDARE"
    echo "Användare '$ANVÄNDARE' skapad."

    HEMKATALOG="/home/$ANVÄNDARE"

    # ─────────────────────────────────────────
    # 3. KATALOGSTRUKTUR OCH RÄTTIGHETER
    # ─────────────────────────────────────────

    # Skapa undermapparna Documents, Downloads och Work
    for MAPP in Documents Downloads Work; do
        mkdir -p "$HEMKATALOG/$MAPP"

        # 700 = endast ägaren kan läsa/skriva/köra
        chmod 700 "$HEMKATALOG/$MAPP"

        # Se till att användaren äger sina egna mappar
        chown "$ANVÄNDARE":"$ANVÄNDARE" "$HEMKATALOG/$MAPP"
    done

    echo "  → Undermappar (Documents, Downloads, Work) skapade med rättigheter 700."

    # Lägg till i listan över skapade användare
    SKAPADE+=("$ANVÄNDARE")
done

# ─────────────────────────────────────────────
# 4. VÄLKOMSTMEDDELANDE (andra passet)
# Nu är ALLA användare skapade, så /etc/passwd är komplett.
# ─────────────────────────────────────────────
for ANVÄNDARE in "${SKAPADE[@]}"; do

    HEMKATALOG="/home/$ANVÄNDARE"
    VÄLKOMSTFIL="$HEMKATALOG/welcome.txt"

    # Rad 1: Personligt välkomstmeddelande
    echo "Välkommen $ANVÄNDARE" > "$VÄLKOMSTFIL"

    # Tom rad för läsbarhet
    echo "" >> "$VÄLKOMSTFIL"

    # Lista alla andra vanliga användare (UID 1000–59999) utom denna användare
    echo "Andra användare på systemet:" >> "$VÄLKOMSTFIL"
    while IFS=: read -r NAMN _ UID _; do
        if [ "$UID" -ge 1000 ] && [ "$UID" -lt 60000 ] && [ "$NAMN" != "$ANVÄNDARE" ]; then
            echo "  - $NAMN" >> "$VÄLKOMSTFIL"
        fi
    done < /etc/passwd

    # Sätt ägare och rättigheter på välkomstfilen
    chown "$ANVÄNDARE":"$ANVÄNDARE" "$VÄLKOMSTFIL"
    chmod 600 "$VÄLKOMSTFIL"

    echo "  → Välkomstfil skapad: $VÄLKOMSTFIL"

done

echo ""
echo "Klart! Alla angivna användare har behandlats."
exit 0
