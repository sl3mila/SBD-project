
-- procedura 1
-- insert new creature
CREATE OR REPLACE PROCEDURE addCreature
(p_type VARCHAR2, p_name VARCHAR2, p_price NUMBER)
IS
    DECLARE
        c_id INT;
        s_id INT;
    BEGIN
        SELECT COUNT(id) + 1 INTO c_id FROM CREATURE;   --creature set ID

        INSERT INTO CREATURE (ID, NAME, PRICE, DONATION_DATE) VALUES (c_id, p_name, p_price, null);

        IF p_type = 'Fish' THEN
            SELECT COUNT(id) + 1 INTO s_id FROM FISH;   --set fish ID

            INSERT INTO FISH (ID, CREATURE_ID) VALUES (s_id, c_id);

        ELSIF p_type = 'Sea_critter' THEN
            SELECT COUNT(id) + 1 INTO s_id FROM SEA_CRITTER;   --set sea critter ID

            INSERT INTO SEA_CRITTER (ID, CREATURE_ID) VALUES (s_id, c_id);

        ELSIF p_type = 'Insect' THEN
            SELECT COUNT(id) + 1 INTO s_id FROM INSECT;   --set insect ID

            INSERT INTO INSECT (ID, CREATURE_ID) VALUES (s_id, c_id);
        end if;
    end;

    BEGIN
        addCreature('Fish', 'Snapping Turtle', 5000);
    end;

-- procedura 2

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE changePrice
(p_price NUMBER)
IS
    c_id INTEGER;
    c_name VARCHAR2;
    c_price NUMBER;

    CURSOR cur IS
        SELECT ID, NAME, PRICE FROM FOSSIL
        WHERE PRICE >= p_price;

    BEGIN

        OPEN cur;
        LOOP
        FETCH cur INTO c_id, c_name, c_price;
        EXIT WHEN cur%NOTFOUND;

            IF c_price < p_price THEN
                UPDATE FOSSIL
                SET PRICE = p_price
                WHERE id = c_id;
                DBMS_OUTPUT.PUT_LINE( c_name || ', with id: ' || c_id || ', price changed');
                end if;
        END LOOP;
        CLOSE cur;
end;

    BEGIN
    findHigherPrices(2000);
end;
-- wyzwalacz 1
CREATE OR REPLACE TRIGGER trigger1
    BEFORE INSERT ON ART
    BEGIN
        IF NEW.NAME = NEW.REAL_NAME THEN
            ROLLBACK;
        end if;
    end;

-- wyzwalacz 2