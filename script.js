// Initialize invoice data
let invoiceData = {
    items: [],
    invoiceNo: 'PI-' + new Date().getFullYear() + '-' + Math.floor(100 + Math.random() * 900),
    date: new Date().toLocaleDateString(),
    lastItemId: 0
};

// Set current date
document.getElementById('currentDate').textContent = new Date().toLocaleDateString();
document.getElementById('invoiceNo').textContent = invoiceData.invoiceNo;
document.getElementById('orderDate').valueAsDate = new Date();

// Add new item row
function addItem() {
    const itemId = ++invoiceData.lastItemId;
    const row = document.createElement('tr');
    row.id = `item-${itemId}`;
    row.innerHTML = `
        <td>${itemId}</td>
        <td><input type="text" class="form-control form-control-sm" value="Glass Panel" onchange="updateItem(${itemId})"></td>
        <td><input type="number" class="form-control form-control-sm" value="1000" min="1" onchange="updateItem(${itemId})"></td>
        <td><input type="number" class="form-control form-control-sm" value="1500" min="1" onchange="updateItem(${itemId})"></td>
        <td><input type="number" class="form-control form-control-sm" value="1" min="1" onchange="updateItem(${itemId})"></td>
        <td><input type="number" class="form-control form-control-sm" value="80" min="1" step="0.01" onchange="updateItem(${itemId})"></td>
        <td class="area">0.00</td>
        <td class="amount">₹0.00</td>
        <td><button class="btn btn-danger btn-sm" onclick="removeItem(${itemId})"><i class="fas fa-trash"></i></button></td>
    `;
    document.getElementById('itemsTable').appendChild(row);
    
    // Add to invoiceData
    invoiceData.items.push({
        id: itemId,
        description: "Glass Panel",
        width: 1000,
        height: 1500,
        qty: 1,
        rate: 80,
        area: 0,
        amount: 0
    });
    
    updateItem(itemId);
}

// Update item calculations
function updateItem(itemId) {
    const row = document.getElementById(`item-${itemId}`);
    const inputs = row.getElementsByTagName('input');
    
    const description = inputs[0].value;
    const width = parseFloat(inputs[1].value) || 0;
    const height = parseFloat(inputs[2].value) || 0;
    const qty = parseInt(inputs[3].value) || 0;
    const rate = parseFloat(inputs[4].value) || 0;
    
    // Calculate area in sq.ft (mm to sq.ft conversion)
    const area = ((width * height) / 92903.04) * qty; // 1 sq.ft = 92903.04 sq.mm
    const amount = area * rate;
    
    // Update display
    row.querySelector('.area').textContent = area.toFixed(2);
    row.querySelector('.amount').textContent = '₹' + amount.toFixed(2);
    
    // Update invoiceData
    const itemIndex = invoiceData.items.findIndex(item => item.id === itemId);
    if (itemIndex > -1) {
        invoiceData.items[itemIndex] = {
            id: itemId,
            description,
            width,
            height,
            qty,
            rate,
            area: parseFloat(area.toFixed(2)),
            amount: parseFloat(amount.toFixed(2))
        };
    }
    
    calculateTotal();
}

// Remove item
function removeItem(itemId) {
    const row = document.getElementById(`item-${itemId}`);
    row.remove();
    
    // Remove from invoiceData
    invoiceData.items = invoiceData.items.filter(item => item.id !== itemId);
    
    calculateTotal();
}

// Calculate totals
function calculateTotal() {
    let subtotal = 0;
    let totalArea = 0;
    
    invoiceData.items.forEach(item => {
        subtotal += item.amount;
        totalArea += item.area;
    });
    
    // Cutting charge (₹10 per sq.ft)
    const cuttingCharge = totalArea * 10;
    
    // Transport (₹500 fixed for now)
    const transport = 500;
    
    // GST (18%)
    const gstRate = 18;
    const gstAmount = (subtotal + cuttingCharge + transport) * (gstRate / 100);
    
    // Total
    const total = subtotal + cuttingCharge + transport + gstAmount;
    
    // Update display
    document.getElementById('subtotal').textContent = '₹' + subtotal.toFixed(2);
    document.getElementById('cuttingCharge').textContent = '₹' + cuttingCharge.toFixed(2);
    document.getElementById('transport').textContent = '₹' + transport.toFixed(2);
    document.getElementById('gstAmount').textContent = '₹' + gstAmount.toFixed(2);
    document.getElementById('totalAmount').textContent = '₹' + total.toFixed(2);
    
    return total;
}

// Generate PDF invoice
function generatePDF() {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    
    // Company Header
    doc.setFontSize(20);
    doc.setTextColor(0, 0, 255);
    doc.text("GLASS FACTORY LTD.", 105, 20, null, null, 'center');
    doc.setFontSize(10);
    doc.setTextColor(0, 0, 0);
    doc.text("123, Industrial Area, Mumbai, Maharashtra", 105, 28, null, null, 'center');
    doc.text("Phone: +91-9876543210 | Email: info@glassfactory.com | GSTIN: 27ABCDE1234F1Z5", 105, 32, null, null, 'center');
    
    // Invoice Title
    doc.setFontSize(16);
    doc.setTextColor(255, 0, 0);
    doc.text("PROFORMA INVOICE", 105, 45, null, null, 'center');
    
    // Invoice Details
    doc.setFontSize(10);
    doc.setTextColor(0, 0, 0);
    doc.text(`Invoice No: ${invoiceData.invoiceNo}`, 150, 55);
    doc.text(`Date: ${new Date().toLocaleDateString()}`, 150, 60);
    doc.text(`Order No: ${document.getElementById('orderNo').value}`, 150, 65);
    
    // Customer Details
    doc.setFontSize(12);
    doc.text("BILL TO:", 20, 75);
    doc.setFontSize(10);
    doc.text(`Name: ${document.getElementById('customerName').value}`, 20, 82);
    doc.text(`Address: ${document.getElementById('customerAddress').value}`, 20, 87);
    doc.text(`Phone: ${document.getElementById('customerPhone').value}`, 20, 92);
    doc.text(`GSTIN: ${document.getElementById('customerGST').value}`, 20, 97);
    
    // Glass Details
    doc.setFontSize(12);
    doc.text("GLASS DETAILS:", 20, 110);
    doc.setFontSize(10);
    doc.text(`Type: ${document.getElementById('glassType').value}`, 20, 117);
    doc.text(`Thickness: ${document.getElementById('thickness').value} mm`, 20, 122);
    
    // Items Table
    const tableData = invoiceData.items.map(item => [
        item.description,
        `${item.width} x ${item.height} mm`,
        item.qty,
        item.area.toFixed(2) + ' sq.ft',
        '₹' + item.rate.toFixed(2),
        '₹' + item.amount.toFixed(2)
    ]);
    
    doc.autoTable({
        startY: 130,
        head: [['Description', 'Size', 'Qty', 'Area', 'Rate', 'Amount']],
        body: tableData,
        theme: 'grid',
        headStyles: { fillColor: [41, 128, 185] }
    });
    
    // Totals
    const finalY = doc.lastAutoTable.finalY + 10;
    const total = calculateTotal();
    
    doc.setFontSize(10);
    doc.text("Subtotal:", 140, finalY);
    doc.text(document.getElementById('subtotal').textContent, 180, finalY);
    
    doc.text("Cutting Charge:", 140, finalY + 5);
    doc.text(document.getElementById('cuttingCharge').textContent, 180, finalY + 5);
    
    doc.text("Transport:", 140, finalY + 10);
    doc.text(document.getElementById('transport').textContent, 180, finalY + 10);
    
    doc.text("GST (18%):", 140, finalY + 15);
    doc.text(document.getElementById('gstAmount').textContent, 180, finalY + 15);
    
    doc.setFontSize(12);
    doc.setTextColor(255, 0, 0);
    doc.text("TOTAL:", 140, finalY + 25);
    doc.text('₹' + total.toFixed(2), 180, finalY + 25);
    
    // Notes
    doc.setFontSize(10);
    doc.setTextColor(0, 0, 0);
    doc.text("Notes:", 20, finalY + 40);
    doc.text(document.getElementById('notes').value, 20, finalY + 47);
    
    doc.text("Terms & Conditions:", 20, finalY + 60);
    doc.text(document.getElementById('terms').value, 20, finalY + 67);
    
    // Save PDF
    doc.save(`Proforma_Invoice_${invoiceData.invoiceNo}.pdf`);
}

// Print invoice
function printInvoice() {
    window.print();
}

// Save invoice data to localStorage
function saveInvoice() {
    const invoice = {
        invoiceNo: invoiceData.invoiceNo,
        date: new Date().toISOString(),
        customer: {
            name: document.getElementById('customerName').value,
            address: document.getElementById('customerAddress').value,
            phone: document.getElementById('customerPhone').value,
            gst: document.getElementById('customerGST').value
        },
        order: {
            orderNo: document.getElementById('orderNo').value,
            orderDate: document.getElementById('orderDate').value,
            glassType: document.getElementById('glassType').value,
            thickness: document.getElementById('thickness').value
        },
        items: invoiceData.items,
        totals: {
            subtotal: document.getElementById('subtotal').textContent,
            cuttingCharge: document.getElementById('cuttingCharge').textContent,
            transport: document.getElementById('transport').textContent,
            gst: document.getElementById('gstAmount').textContent,
            total: document.getElementById('totalAmount').textContent
        },
        notes: document.getElementById('notes').value,
        terms: document.getElementById('terms').value
    };
    
    // Save to localStorage
    localStorage.setItem(`invoice_${invoiceData.invoiceNo}`, JSON.stringify(invoice));
    
    // Save to list
    let invoices = JSON.parse(localStorage.getItem('invoices') || '[]');
    invoices.push({
        id: invoiceData.invoiceNo,
        date: invoice.date,
        customer: invoice.customer.name,
        total: invoice.totals.total
    });
    localStorage.setItem('invoices', JSON.stringify(invoices));
    
    alert(`Invoice ${invoiceData.invoiceNo} saved successfully!`);
}

// Reset form
function resetForm() {
    if (confirm("Are you sure you want to reset the form? All data will be lost.")) {
        invoiceData = {
            items: [],
            invoiceNo: 'PI-' + new Date().getFullYear() + '-' + Math.floor(100 + Math.random() * 900),
            date: new Date().toLocaleDateString(),
            lastItemId: 0
        };
        
        document.getElementById('itemsTable').innerHTML = '';
        document.getElementById('customerName').value = '';
        document.getElementById('customerAddress').value = '';
        document.getElementById('customerPhone').value = '';
        document.getElementById('customerGST').value = '';
        document.getElementById('orderNo').value = 'ORD-' + new Date().getFullYear() + '-' + Math.floor(100 + Math.random() * 900);
        document.getElementById('invoiceNo').textContent = invoiceData.invoiceNo;
        document.getElementById('subtotal').textContent = '₹0.00';
        document.getElementById('cuttingCharge').textContent = '₹0.00';
        document.getElementById('transport').textContent = '₹0.00';
        document.getElementById('gstAmount').textContent = '₹0.00';
        document.getElementById('totalAmount').textContent = '₹0.00';
        
        // Add one default item
        addItem();
    }
}

// Dispatch Tracking Function (Bonus Feature)
function addDispatchTracking() {
    const dispatchData = {
        invoiceNo: invoiceData.invoiceNo,
        customer: document.getElementById('customerName').value,
        address: document.getElementById('customerAddress').value,
        items: invoiceData.items.length,
        totalAmount: document.getElementById('totalAmount').textContent,
        status: "Ready for Dispatch",
        dispatchDate: new Date().toISOString().split('T')[0],
        estimatedDelivery: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        trackingId: 'TRK' + Math.floor(100000 + Math.random() * 900000)
    };
    
    // Save dispatch data
    localStorage.setItem(`dispatch_${invoiceData.invoiceNo}`, JSON.stringify(dispatchData));
    
    alert(`Dispatch tracking created! Tracking ID: ${dispatchData.trackingId}`);
}

// Add dispatch button to UI
window.onload = function() {
    // Add default item
    addItem();
    
    // Add dispatch button
    const buttonContainer = document.querySelector('.row.mt-4 .col-md-12');
    const dispatchBtn = document.createElement('button');
    dispatchBtn.className = 'btn btn-dark btn-gap';
    dispatchBtn.innerHTML = '<i class="fas fa-truck"></i> Create Dispatch';
    dispatchBtn.onclick = addDispatchTracking;
    buttonContainer.appendChild(dispatchBtn);
};
