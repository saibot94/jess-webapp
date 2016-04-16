package servlets;

import java.io.IOException;
import java.util.Iterator;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jess.Fact;
import jess.JessException;
import jess.RU;
import jess.Rete;
import jess.Value;
import jess.ValueVector;

@WebServlet("/Order/purchase")
public class Purchase extends BaseServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		checkInitialized();

		ServletContext context = getServletContext();
		String orderNumberString = (String) req.getSession().getAttribute(
				"orderNumber");
		String customerIdString = (String) req.getSession().getAttribute(
				"customerId");
		if (orderNumberString == null || customerIdString == null) {
			dispatch(req, resp, "/");
			return;
		}
		try {
			Rete engine = (Rete) context.getAttribute("engine");
			int orderNumber = Integer.parseInt(orderNumberString);
			Value orderNumberValue = new Value(orderNumber, RU.INTEGER);
			Value customerIdValue = new Value(customerIdString, RU.ATOM);
			String[] items = (String[]) req.getParameterValues("items");
			if (items != null) {
				System.out.println("These are the order items: ");
				for (String orderItem : items) {
					System.err.println(orderItem);
					Fact item = new Fact("line-item", engine);
					item.setSlotValue("order-number", orderNumberValue);
					item.setSlotValue("customer-id", customerIdValue);
					item.setSlotValue("part-number", new Value(orderItem,
							RU.ATOM));
					engine.assertFact(item);
				}
			}
			engine.run();
			Iterator result = engine.runQuery("items-for-order",
					new ValueVector().add(orderNumberValue));
			req.setAttribute("queryResult", result);
		
			dispatch(req, resp, "/purchase.jsp");
		} catch (JessException je) {
			throw new ServletException(je);
		}

	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		doGet(req, resp);
	}
}
