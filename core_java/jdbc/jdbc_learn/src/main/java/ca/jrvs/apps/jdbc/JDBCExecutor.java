package ca.jrvs.apps.jdbc;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.List;

public class JDBCExecutor {

    public static void main(String... args){
        DatabaseConnectionManager dcm = new DatabaseConnectionManager("localhost",
                "hplussport", "postgres", "password");
        try{
            /* Code for EXECUTE QUERY ""SELECT COUNT(*) FROM CUSTOMER", need DatabaseConnectionManager.java */
            /*Connection connection = dcm.getConnection(); // Build a sql Connection using java.sql.Connection API
            Statement statement = connection.createStatement(); // create a Statement for execute query
            ResultSet resultSet = statement.executeQuery("SELECT COUNT(*) FROM CUSTOMER");
            while(resultSet.next()) {
                System.out.println(resultSet.getInt(1));
            }*/

            /* code for INSERT DATA for Customer Table, need DatabaseConnectionManager.java, CustomerDAO.java,
            DataAccessObject.java, DataTransferObject.java */
            /*Connection connection = dcm.getConnection();
            CustomerDAO customerDAO = new CustomerDAO(connection);
            Customer customer = new Customer();
            customer.setFirstName("George");
            customer.setLastName("Washington");
            customer.setEmail("george.washington@wh.gov");
            customer.setPhone("(555) 555-6543");
            customer.setAddress("1234 Main St");
            customer.setCity("Mount Vernon");
            customer.setState("VA");
            customer.setZipCode("22121");
            customerDAO.create(customer);*/

            /* code for SELECT DATA for Customer Table, need DatabaseConnectionManager.java, CustomerDAO.java,
            DataAccessObject.java, DataTransferObject.java */
            /*Connection connection = dcm.getConnection();
            CustomerDAO customerDAO = new CustomerDAO(connection);
            Customer customer = customerDAO.findById(999);
            System.out.println(customer.getFirstName() + " " + customer.getLastName());*/

            /* code for UPDATE DATA for Customer Table, need DatabaseConnectionManager.java, CustomerDAO.java,
            DataAccessObject.java, DataTransferObject.java */
            /*Connection connection = dcm.getConnection();
            CustomerDAO customerDAO = new CustomerDAO(connection);
            Customer customer = customerDAO.findById(10000);
            System.out.println(customer.getFirstName() + " " + customer.getLastName() + " " +
                    customer.getEmail());
            customer.setEmail("gwashington@wh.gov");
            customer = customerDAO.update(customer);
            System.out.println(customer.getFirstName() + " " + customer.getLastName() + " " +
                    customer.getEmail());*/

            /* code for DELETE DATA for Customer Table, need DatabaseConnectionManager.java, CustomerDAO.java,
            DataAccessObject.java, DataTransferObject.java */
            /*Connection connection = dcm.getConnection();
            CustomerDAO customerDAO = new CustomerDAO(connection);
            Customer customer = new Customer();
            customer.setFirstName("John");
            customer.setLastName("Adams");
            customer.setEmail("jadams.wh.gov");
            customer.setAddress("1234 Main St");
            customer.setCity("Arlington");
            customer.setState("VA");
            customer.setPhone("(555) 555-9845");
            customer.setZipCode("01234");

            Customer dbCustomer = customerDAO.create(customer); // CREATE DATA
            System.out.println(dbCustomer);
            dbCustomer = customerDAO.findById(dbCustomer.getId()); // FIND DATA BY ID
            System.out.println(dbCustomer);
            dbCustomer.setEmail("john.adams@wh.gov");
            dbCustomer = customerDAO.update(dbCustomer); // UPDATE DATA
            System.out.println(dbCustomer);
            customerDAO.delete(dbCustomer.getId()); // DELETE DATA

            Connection connection = dcm.getConnection();
            OrderDAO orderDAO = new OrderDAO(connection);
            Order order = orderDAO.findById(1000);
            System.out.println(order);*/

            /* get results from stored procedure.*/
            Connection connection = dcm.getConnection();
            OrderDAO orderDAO = new OrderDAO(connection);
            List<Order> orders = orderDAO.getOrdersForCustomer(789);
            orders.forEach(System.out::println);*/

            /* get sorted limited results from stored procedure.*/
            Connection connection = dcm.getConnection();
            CustomerDAO customerDAO = new CustomerDAO(connection);
            customerDAO.findAllSorted(20).forEach(System.out::println);

            /* get soretd limited resukts with offset */
            Connection connection = dcm.getConnection();
            CustomerDAO customerDAO = new CustomerDAO(connection);
            customerDAO.findAllSorted(20).forEach(System.out::println);
            System.out.println("Paged");
            for(int i=1;i<3;i++){
                System.out.println("Page number: " + i);
                customerDAO.findAllPaged(10, i).forEach(System.out::println);
            }

        }catch(SQLException e){
            e.printStackTrace();
        }
    }
}
