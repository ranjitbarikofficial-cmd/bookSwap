
package Entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "swap_requests")
public class SwapRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "requester_id", nullable = false)
    private Seller requester;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "owner_id", nullable = false)
    private Seller owner;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "offered_book_id", nullable = false)
    private Book offeredBook;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "requested_book_id", nullable = false)
    private Book requestedBook;

    @Column(nullable = false, length = 20)
    private String status = "PENDING";

    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    private LocalDateTime updatedAt;

    public SwapRequest() {
    }

    public Long getId() {
        return id;
    }

    public Seller getRequester() {
        return requester;
    }

    public void setRequester(Seller requester) {
        this.requester = requester;
    }

    public Seller getOwner() {
        return owner;
    }

    public void setOwner(Seller owner) {
        this.owner = owner;
    }

    public Book getOfferedBook() {
        return offeredBook;
    }

    public void setOfferedBook(Book offeredBook) {
        this.offeredBook = offeredBook;
    }

    public Book getRequestedBook() {
        return requestedBook;
    }

    public void setRequestedBook(Book requestedBook) {
        this.requestedBook = requestedBook;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
        this.updatedAt = LocalDateTime.now();
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
}
