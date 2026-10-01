package Service;

import Dao.SellerDAO;
import Entity.Seller;

public class SellerService {

    private final SellerDAO sellerDAO;

    public SellerService() {
        this.sellerDAO = new SellerDAO();
    }

    public void saveSeller(Seller seller) {
        sellerDAO.saveSeller(seller);
    }

    public Seller getSellerById(Long id) {
        return sellerDAO.getSellerById(id);
    }

    public void updateSeller(Seller seller) {
        sellerDAO.updateSeller(seller);
    }

    public void deleteSeller(Long id) {
        sellerDAO.deleteSeller(id);
    }
}