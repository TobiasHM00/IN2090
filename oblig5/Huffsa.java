import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet; 
import java.sql.SQLException;

import java.util.Scanner;

public class Huffsa {

    private static String user = "tobiashm"; // Skriv ditt UiO-brukernavn
    private static String pwd = "Dansk100"; // Skriv passordet til _priv-brukeren du fikk i mail fra USIT
    // Tilkoblings-detaljer
    private static String connectionStr = 
        "user=" + user + "_priv&" + 
        "port=5432&" +  
        "password=" + pwd + "";
    private static String host = "jdbc:postgresql://dbpg-ifi-kurs03.uio.no"; 

    public static void main(String[] agrs) {
        try {
            // Last inn driver for PostgreSQL
            Class.forName("org.postgresql.Driver");
            // Lag tilkobling til databasen
            Connection connection = DriverManager.getConnection(host + "/" + user
                    + "?sslmode=require&ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory&" + connectionStr);

            int ch = 0;
            while (ch != 3) {
                System.out.println("--[ HUFFSA ]--");
                System.out.println("Vennligst velg et alternativ:\n 1. Søk etter planet\n 2. Legg inn resultat\n 3. Avslutt");
                ch = getIntFromUser("Valg: ", true);

                if (ch == 1) {
                    planetSok(connection);
                } else if (ch == 2) {
                    leggInnResultat(connection);
                }
            }
        } catch (SQLException|ClassNotFoundException ex) {
            System.err.println("Error encountered: " + ex.getMessage());
        }
    }

    private static void planetSok(Connection connection)  throws SQLException {
        System.out.println("--[ PLANET-SØK ]--");
        String molekyl1 = getStrFromUser("Molekyl 1: ");
        String molekyl2 = getStrFromUser("Molekyl 2: ");

        String q = "SELECT p.navn, p.masse, s.masse, s.avstand, p.liv " + 
                    "FROM planet AS p " +
                        "JOIN stjerne AS s ON (p.stjerne = s.navn) " +
                        "JOIN materie AS m ON (p.navn = m.planet) " + 
                    "WHERE m.molekyl LIKE ?";

        if(!molekyl2.equals("")){
            q += " AND m.molekyl LIKE ?";
        }
        q += "order by s.avstand;";

        PreparedStatement statement = connection.prepareStatement(q);

        statement.setString(1, '%' + molekyl1 + '%');
        if(!molekyl2.equals("")){
            statement.setString(2, '%' + molekyl2 + '%');
        }

        ResultSet rows = statement.executeQuery();

        if(!rows.next()){
            System.out.println("No result");
            return;
        }

        do {
            System.out.println("--Planet--");
            System.out.println("Navn: " + rows.getString(1) +
            "\nPlanet-masse: " + rows.getDouble(2) + 
            "\nStjerne-masse: " + rows.getDouble(3) + 
            "\nStjerne-avstand: " + rows.getDouble(4));

            if(rows.getBoolean(5)){
                System.out.println("Bekreftet liv: Ja\n");
            } else{
                System.out.println("Bekreftet liv: Nei\n");
            }
        } while (rows.next());
    }

    private static void leggInnResultat(Connection connection) throws SQLException {
        String planet = getStrFromUser("Planet: ");
        String skummel = getStrFromUser("Skummel: ");
        String inte = getStrFromUser("Intelligent: ");
        String besk = getStrFromUser("Beskrivelse: ");

        String q = "UPDATE planet " + 
                   "SET liv = true, skummel = ?, intelligent = ?, beskrivelse = ? " + 
                   "WHERE navn = ?;";
        
        boolean skum = true;
        boolean intelle = true;
        if(skummel.equals("j")){
            skum = true;
        } else{
            skum = false;
        }
        if(inte.equals("j")){
            intelle = true;
        } else{
            intelle = false;
        }

        PreparedStatement statement = connection.prepareStatement(q);
        statement.setBoolean(1, skum);
        statement.setBoolean(2, intelle);
        statement.setString(3, besk);
        statement.setString(4, planet);

        statement.execute();
        System.out.println("Resultat lagt inn\n");
    }

    /**
     * Utility method that gets an int as input from user
     * Prints the argument message before getting input
     * If second argument is true, the user does not need to give input and can leave
     * the field blank (resulting in a null)
     */
    private static Integer getIntFromUser(String message, boolean canBeBlank) {
        while (true) {
            String str = getStrFromUser(message);
            if (str.equals("") && canBeBlank) {
                return null;
            }
            try {
                return Integer.valueOf(str);
            } catch (NumberFormatException ex) {
                System.out.println("Please provide an integer or leave blank.");
            }
        }
    }

    /**
     * Utility method that gets a String as input from user
     * Prints the argument message before getting input
     */
    private static String getStrFromUser(String message) {
        Scanner s = new Scanner(System.in);
        System.out.print(message);
        return s.nextLine();
    }
}
