package servlets;

import java.io.File;
import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jess.Batch;
import jess.JessException;
import jess.Rete;

public abstract class BaseServlet extends HttpServlet{

	protected void dispatch(HttpServletRequest request,
			HttpServletResponse response, String page) throws ServletException, IOException {
		ServletContext context = request.getServletContext();
		RequestDispatcher dispatcher = context.getRequestDispatcher(page);
		dispatcher.forward(request, response);
	}
	
	protected void checkInitialized() throws ServletException {
		ServletContext servletContext = getServletContext();
		String path = servletContext.getRealPath("/");

		String rulesFile = path + servletContext.getInitParameter("rulesfile");
		String factsFile = path + servletContext.getInitParameter("factsfile");
		factsFile = factsFile.replace('\\', '/');
		
		if (servletContext.getAttribute("engine") == null) {
			try {
				Rete engine = new Rete(this);
				Batch.batch(rulesFile, engine);
				engine.reset();

				if (new File(factsFile).exists()) {
					engine.executeCommand("(load-facts " + factsFile + ")");
				}
				engine.setFocus("MAIN");
				servletContext.setAttribute("engine", engine);
			} catch (JessException e) {
				e.printStackTrace();
				throw new ServletException(e);
			}

		}
	}

}
