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

@WebServlet("/Order/recommend")
public class Recommend extends BaseServlet {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		checkInitialized();
		ServletContext context = getServletContext();

		String[] items = req.getParameterValues("items");
		String orderNumberString = (String) req.getSession().getAttribute(
				"orderNumber");
		String customerIdString = (String) req.getSession().getAttribute(
				"customerId");

		if (items == null || customerIdString == null
				|| orderNumberString == null) {
			dispatch(req, resp, "/");
			return;
		}

		try {
			Rete engine = (Rete) context.getAttribute("engine");
			System.out.println("This is my order number string: "
					+ orderNumberString);
			engine.executeCommand("(watch all)");
			int orderNumber = Integer.parseInt(orderNumberString);

			
			Value customerIdValue = new Value(customerIdString, RU.ATOM);
			Value orderNumberValue = new Value(orderNumber, RU.INTEGER);
			Fact order = new Fact("order", engine);

			order.setSlotValue("order-number", orderNumberValue);
			order.setSlotValue("customer-id", customerIdValue);
			engine.assertFact(order);

			addCleanUpFact(orderNumberString, engine);
		
			
			engine.run();


		
			for (String orderItem : items) {
				Fact item = new Fact("line-item", engine);
				item.setSlotValue("order-number", orderNumberValue);
				item.setSlotValue("part-number", new Value(orderItem, RU.ATOM));
				item.setSlotValue("customer-id", customerIdValue);
				engine.assertFact(item);
			}

			engine.run();
			
			engine.executeCommand("(ppdefrule recommend-same-type-of-media)");
			System.out.println("After the run: \n");
			Iterator result = engine.runQuery("recommendations-for-order",
					new ValueVector().add(orderNumberValue));
			if (result.hasNext()) {
				req.setAttribute("queryResult", result);
				dispatch(req, resp, "/recommend.jsp");
			} else {
				dispatch(req, resp, "/Order/purchase/");
			}
		} catch (JessException je) {
			throw new ServletException(je);
		}

	}

	private void addCleanUpFact(String orderNumberString, Rete engine) throws JessException {
		
		Fact cleanUpFact = new Fact("clean-up-order", engine);
		cleanUpFact.setSlotValue("__data",
				new Value(new ValueVector().add(orderNumberString),
						RU.LIST));
		engine.assertFact(cleanUpFact);		
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		doGet(req, resp);
	}
}
