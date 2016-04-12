package servlets;

import java.io.File;
import java.io.IOException;
import java.util.Iterator;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import jess.Batch;
import jess.Deffacts;
import jess.JessException;
import jess.Rete;
import jess.ValueVector;

/**
 * Servlet implementation class Catalog
 */
@WebServlet("/Order/catalog")
public class Catalog extends BaseServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public Catalog() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		checkInitialized();
		try {
			String customerId = (String) request.getParameter("customerId");
			if (customerId == null || customerId.length() == 0) {
				dispatch(request, response, "/");
			}
			else{ 
				// start the new login
				request.getSession().invalidate();
				HttpSession session = request.getSession();

				session.setAttribute("customerId", customerId);

				session.setAttribute("orderNumber",
						String.valueOf(getNewOrderNumber()));
				System.out.println(session.getAttribute("orderNumber"));
				runProductQuery(request);
				dispatch(request, response, "/catalog.jsp");	
			}
		}
		catch (JessException je) {
			throw new ServletException(je);
		}
	}

	private int getNewOrderNumber() throws JessException {
		ServletContext servletContext = getServletContext();
		Rete engine = (Rete) servletContext.getAttribute("engine");
		String command = "(get-new-order-number)";
		int nextOrderNumber = engine.executeCommand(command).intValue(null);
		return nextOrderNumber;
	}

	private void runProductQuery(ServletRequest request) throws JessException {
		ServletContext context = getServletContext();
		Rete engine = (Rete) context.getAttribute("engine");
		Iterator result = engine.runQuery("all-products", new ValueVector());
		request.setAttribute("queryResult", result);
	}


	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

}
