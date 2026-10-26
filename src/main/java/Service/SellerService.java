package Service;

import Dao.SellerDAO;
import Entity.Seller;

import java.util.List;
import java.util.Optional;

public class SellerService {

    private final SellerDAO sellerDAO;

    public SellerService() {
        this.sellerDAO = new SellerDAO();
    }

    public void saveSeller(Seller seller) {
        sellerDAO.saveSeller(seller);
    }

    public List<Seller> getAllSellers() {
        return sellerDAO.getAllSellers();
    }

    public Seller getSellerById(Long id) {
        return sellerDAO.getSellerById(id);
    }

    public Seller getSellerByEmail(String email) {
        return sellerDAO.getSellerByEmail(email);
    }

    public void updateSeller(Seller seller) {
        sellerDAO.updateSeller(seller);
    }

    public void deleteSeller(Long id) {
        sellerDAO.deleteSeller(id);
    }

}