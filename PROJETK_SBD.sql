
-- procedura 1
-- insert new creature
CREATE OR REPLACE PROCEDURE createCreature (
    p_name VARCHAR2,
    p_price NUMBER
)
IS
    creature_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO creature_exists
    FROM CREATURE
    WHERE NAME = p_name;

    --check if exists
    IF creature_exists > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Creature ' || p_name || ' already exists. Cannot create.');
    ELSE
        DECLARE
            c_id INT;
        BEGIN
            SELECT MAX(ID) + 1 INTO c_id FROM CREATURE;

            IF c_id IS NULL THEN
                c_id := 1;
            END IF;

            INSERT INTO CREATURE (ID, NAME, PRICE, DONATION_DATE)
            VALUES (c_id, p_name, p_price, NULL);

            DBMS_OUTPUT.PUT_LINE('Creature ' || p_name || ' created');
        END;
    END IF;
END;

BEGIN
    createCreature('Snapping Turtle', 5000);
END;

-- procedura 2

SET SERVEROUTPUT ON;

-- zmienia ceny w skamielinach - Fossils
CREATE OR REPLACE PROCEDURE changePrice
(where_price NUMBER, to_price NUMBER)
IS
    c_id INTEGER;
    c_name VARCHAR2(30);
    c_price NUMBER;

    CURSOR cur IS
        SELECT ID, NAME, PRICE FROM FOSSIL
        WHERE PRICE >= where_price
        FOR UPDATE;

    BEGIN

        OPEN cur;
        LOOP
            FETCH cur INTO c_id, c_name, c_price;
            EXIT WHEN cur%NOTFOUND;

            IF c_price < where_price THEN
                UPDATE FOSSIL
                SET PRICE = to_price
                WHERE id = c_id;

                DBMS_OUTPUT.PUT_LINE( c_name || ', with id: ' || c_id || ', price changed');
                end if;
        END LOOP;
        CLOSE cur;
end;

BEGIN
    changePrice(2000, 3000);
end;


-- wyzwalacz 1

CREATE OR REPLACE TRIGGER trig1
BEFORE INSERT OR UPDATE ON CREATURE
FOR EACH ROW
DECLARE
    t_name NUMBER;
    t_price NUMBER;
BEGIN

    --insert
    SELECT COUNT(*) INTO t_name
    FROM (
        SELECT NAME FROM CREATURE WHERE NAME = NEW.NAME
    );

    IF t_name > 0 THEN
        RAISE_APPLICATION_ERROR(-1, 'Cannot add');
    END IF;

    --update
    SELECT PRICE INTO t_price
    FROM CREATURE;

    IF t_price IS NOT NULL AND NEW.PRICE < 100 THEN
        RAISE_APPLICATION_ERROR(-2, 'Cannot change price');
    end if;
END;

INSERT INTO CREATURE (ID, NAME, PRICE, DONATION_DATE) VALUES (20, 'Snappring Turtle', 2, NULL);

-- wyzwalacz 2

CREATE OR REPLACE TRIGGER trig2
BEFORE INSERT OR UPDATE OR DELETE ON ART
FOR EACH ROW
DECLARE
    t_date DATE := SYSDATE; -- current date
BEGIN

    IF INSERTING AND NEW.DONATION_DATE > t_date THEN
        RAISE_APPLICATION_ERROR(-3, 'Cannot insert - donation date higher than the present date');
    END IF;

    IF UPDATING AND NEW.DONATION_DATE > t_date THEN
        RAISE_APPLICATION_ERROR(-4, 'Cannot update - donation date higher than the present date');
    END IF;

    IF UPDATING AND NEW.REAL_NAME != OLD.REAL_NAME THEN
        RAISE_APPLICATION_ERROR(-5, 'Cannot update name');
    end if;

    IF DELETING AND OLD.ARTIST = 'Rembrandt van Rijn' THEN
        RAISE_APPLICATION_ERROR(-6, 'Cannot delete Rembrandt van Rijn');
    end if;
END;
