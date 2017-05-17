import java.awt.Point;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;


import org.citygml4j.builder.CityGMLBuilder;
import org.citygml4j.CityGMLContext;
import org.citygml4j.builder.jaxb.JAXBBuilder;

import org.citygml4j.factory.DimensionMismatchException;
import org.citygml4j.factory.GMLGeometryFactory;
import org.citygml4j.model.citygml.CityGMLClass;
import org.citygml4j.model.citygml.building.AbstractBoundarySurface;
import org.citygml4j.model.citygml.building.BoundarySurfaceProperty;
import org.citygml4j.model.citygml.building.Building;
import org.citygml4j.model.citygml.building.Door;
import org.citygml4j.model.citygml.building.FloorSurface;
import org.citygml4j.model.citygml.building.GroundSurface;
import org.citygml4j.model.citygml.building.InteriorWallSurface;
import org.citygml4j.model.citygml.building.OpeningProperty;
import org.citygml4j.model.citygml.building.RoofSurface;
import org.citygml4j.model.citygml.building.WallSurface;
import org.citygml4j.model.citygml.building.Window;
import org.citygml4j.model.citygml.core.CityModel;
import org.citygml4j.model.citygml.core.CityObjectMember;
import org.citygml4j.model.gml.geometry.aggregates.MultiSurface;
import org.citygml4j.model.gml.geometry.aggregates.MultiSurfaceProperty;
import org.citygml4j.model.gml.geometry.complexes.CompositeSurface;
import org.citygml4j.model.gml.geometry.primitives.DirectPositionList;
import org.citygml4j.model.gml.geometry.primitives.Exterior;
import org.citygml4j.model.gml.geometry.primitives.LinearRing;
import org.citygml4j.model.gml.geometry.primitives.Polygon;
import org.citygml4j.model.gml.geometry.primitives.Solid;
import org.citygml4j.model.gml.geometry.primitives.SolidProperty;
import org.citygml4j.model.gml.geometry.primitives.SurfaceProperty;
import org.citygml4j.model.module.citygml.CityGMLVersion;
import org.citygml4j.util.gmlid.DefaultGMLIdManager;
import org.citygml4j.util.gmlid.GMLIdManager;
import org.citygml4j.xml.io.CityGMLOutputFactory;
import org.citygml4j.xml.io.writer.CityGMLWriter;
import java.sql.*;


public class LoD1Generator {
	public static void main (String[]args ) throws Exception{
		new LoD1Generator().doMain();
		
	}
	
		
	public void doMain() throws Exception {
		SimpleDateFormat df = new SimpleDateFormat("[HH:mm:ss] "); 

		System.out.println(df.format(new Date()) + "setting up citygml4j context and JAXB builder");
		CityGMLContext ctx = new CityGMLContext();
		CityGMLBuilder builder = ctx.createCityGMLBuilder();

		System.out.println(df.format(new Date()) + "creating LOD1 building as citygml4j in-memory object tree");
		GMLGeometryFactory geom = new GMLGeometryFactory();
		JAXBBuilder builder2 = ctx.createJAXBBuilder();
		
		System.out.println(df.format(new Date()) + "creating LOD1 building as citygml4j in-memory object tree");
		GMLGeometryFactory geom2 = new GMLGeometryFactory();
		

		GMLIdManager gmlIdManager = DefaultGMLIdManager.getInstance();

		Building building = new Building();
        // for ground
		List<Double> lst = new ArrayList<Double>();
		
		int count = 0; // counts number of vertices of footprint
		
         try{
			
			
			// 1. get connection to database
			// note: demo is name of database in mysql- student is username and password- 3306 is port number
			Connection myConn = DriverManager.getConnection("jdbc:Mysql://localhost:3306/lod0?useSSL=false","root","student");
			// 2. create a statement
					Statement myStmt = myConn.createStatement();
			// 3. execute a sql query
					ResultSet myRs = myStmt.executeQuery("select * from building_footprint");
			// 4. process the result set
					
					
					 
					while (myRs.next()){
						double x = myRs.getDouble("x");
						double y = myRs.getDouble("y");
						double z = 0;
						lst.add(x);
						lst.add(y);
						lst.add(z);
						  count++;
					}
					
		}
         catch (Exception exc){
 			exc.printStackTrace();
 		
 		}
         double[] myArrayForGround = new double[lst.size()];
         for (int i = 0; i < lst.size(); i++) {
        	   myArrayForGround[i] = lst.get(i);
        	   System.out.println(myArrayForGround[i]);
        	   
        	}
         System.out.println(myArrayForGround);
		
		Polygon ground = geom.createLinearPolygon(myArrayForGround,3);
		
		// adding height value to ground vertices
		double[] myArrayForRoof = new double[lst.size()];
		for (int i =0; i< lst.size(); i++)
		myArrayForRoof[i] = myArrayForGround[i];
	
		for (int i =2; i< lst.size(); i+=3){
			
			myArrayForRoof[i]+=12;		
		}
		
for (int i =0; i< lst.size(); i++){
			
	System.out.println(myArrayForRoof[i]);	
			
		}

		Polygon roof = geom.createLinearPolygon(myArrayForRoof,3);
		
		// Assume number of floors are calculated from the classification algorithm
		// Assume we calculated each floor height
		
		int num_of_floors = 4;
		int [] floor_heights = {3,3,3,3};
		
		List<Polygon> floors = new ArrayList<Polygon>();
		Polygon f = geom.createLinearPolygon(myArrayForRoof,3);
		
		double[] myArrayForFloor = new double[lst.size()];
		for (int i =0; i< lst.size(); i++)
		myArrayForRoof[i] = myArrayForGround[i];
	
		for (int i =2; i< lst.size(); i+=3){
			
			myArrayForRoof[i]+=floor_heights[0];		
		}
		Polygon floor_1 = geom.createLinearPolygon(myArrayForRoof,3);
		
		
		
		
		
		
		
		List<Polygon> walls = new ArrayList<Polygon>();
        
        //--------walls---------------
		
		//lst.size()/3
		
        int k=0;
        for (int i=0; i<lst.size()/3; i++){
       	 walls.add(geom.createLinearPolygon(new double[] {
       			 myArrayForGround[k],myArrayForGround[k+1], myArrayForGround[k+2], 
       			 myArrayForGround[k+3],myArrayForGround[k+4], myArrayForGround[k+5],
       			 myArrayForGround[k+3],myArrayForGround[k+4], myArrayForGround[k+5]+12,
       			 myArrayForGround[k],myArrayForGround[k+1], myArrayForGround[k+2]+12,
       			 myArrayForGround[k],myArrayForGround[k+1], myArrayForGround[k+2]},3));
      if (k+3 <lst.size()-3)
       			k+=3;
        }
        
        
        System.out.println(walls.size());
        for (int i=0; i<walls.size(); i++){
       	 walls.get(i).setId(gmlIdManager.generateUUID());
        }
        
        
	
        //----------------------------
		
		
		ground.setId(gmlIdManager.generateUUID());
		roof.setId(gmlIdManager.generateUUID());
		floor_1.setId(gmlIdManager.generateUUID());
		
		
		List<SurfaceProperty> surfaceMember = new ArrayList<SurfaceProperty>();
		surfaceMember.add(new SurfaceProperty('#' + ground.getId()));
		surfaceMember.add(new SurfaceProperty('#' + roof.getId()));
		for (int i=0; i<walls.size(); i++){
			surfaceMember.add(new SurfaceProperty('#' + walls.get(i).getId()));
	        }
		
		// Assume an I/O detected at wall number 1
		int I_O = 1;
		BoundarySurfaceProperty wall_1_BSurf = createBoundarySurface(CityGMLClass.BUILDING_WALL_SURFACE, walls.get(I_O));		
		createDoor(wall_1_BSurf);	
		
		
		
		
		CompositeSurface compositeSurface = new CompositeSurface();
		compositeSurface.setSurfaceMember(surfaceMember);		
		Solid solid = new Solid();
		solid.setExterior(new SurfaceProperty(compositeSurface));

		building.setLod4Solid(new SolidProperty(solid));
		
		// thematic boundary surfaces
				List<BoundarySurfaceProperty> boundedBy = new ArrayList<BoundarySurfaceProperty>();
				boundedBy.add(createBoundarySurface(CityGMLClass.BUILDING_GROUND_SURFACE, ground));
				boundedBy.add(createBoundarySurface(CityGMLClass.BUILDING_ROOF_SURFACE, roof));
				boundedBy.add(createBoundarySurface(CityGMLClass.BUILDING_FLOOR_SURFACE, floor_1));
				boundedBy.add(wall_1_BSurf);
				for (int i=0; i<walls.size(); i++){
					boundedBy.add(createBoundarySurface(CityGMLClass.BUILDING_WALL_SURFACE, walls.get(i)));
			        }
				
				building.setBoundedBySurface(boundedBy);

				CityModel cityModel = new CityModel();
				cityModel.setBoundedBy(building.calcBoundedBy(false));
				cityModel.addCityObjectMember(new CityObjectMember(building));

				System.out.println(df.format(new Date()) + "writing citygml4j object tree");
				CityGMLOutputFactory out = builder.createCityGMLOutputFactory(CityGMLVersion.DEFAULT);
				CityGMLWriter writer = out.createCityGMLWriter(new File("LoD1Generated.gml"));

				writer.setPrefixes(CityGMLVersion.DEFAULT);
				writer.setSchemaLocations(CityGMLVersion.DEFAULT);
				writer.setIndentString("  ");
				writer.write(cityModel);
				writer.close();	
				
				System.out.println(df.format(new Date()) + "CityGML file LOD0Generated.gml written");
				System.out.println(df.format(new Date()) + "sample citygml4j application successfully finished");
				
	}
	
	public void createDoor(BoundarySurfaceProperty bsp) throws DimensionMismatchException {
		System.out.println("c");
		AbstractBoundarySurface b = bsp.getBoundarySurface();
		if (b instanceof WallSurface) {
			System.out.println("IS wall surf");
			
			GMLGeometryFactory geom = new GMLGeometryFactory();
			
			WallSurface ws = (WallSurface) b;
			
			Door door = new Door();
			
			OpeningProperty openingProperty = new OpeningProperty();			
			openingProperty.setObject(door);			
			
			
			
			
			Polygon doorPoly= geom.createLinearPolygon(new double[] {-3.5,0.1,0, -6.5,0.1,0, -6.5,0.1,2.3, -3.5,0.1,2.3, -3.5,0.1,0}, 3);
			Polygon doorPoly2 = geom.createLinearPolygon(new double[] {-3.5,-0.1,0, -6.5,-0.1,0, -6.5,-0.1,2.3, -3.5,-0.1,2.3, -3.5,-0.1,0}, 3);
			List l = new ArrayList();
			l.add(doorPoly);
			l.add(doorPoly2);
			
			//door.setLod4MultiSurface(gml.createMultiSurfaceProperty(gml.createMultiSurface(doorPoly)));
			door.setLod4MultiSurface(new MultiSurfaceProperty(new MultiSurface(l)));
			
			ws.addOpening(openingProperty);
		}				
	}
	        
	private BoundarySurfaceProperty createBoundarySurface(CityGMLClass type, Polygon geometry) {
		AbstractBoundarySurface boundarySurface = null;

		switch (type) {
	
		case BUILDING_GROUND_SURFACE:
			boundarySurface = new GroundSurface();
			break;
		case BUILDING_ROOF_SURFACE:
			boundarySurface = new RoofSurface();
			break;
		case BUILDING_WALL_SURFACE:
			boundarySurface = new WallSurface();
			break;
		case BUILDING_FLOOR_SURFACE:
			boundarySurface = new FloorSurface();
			break;
			
		default:
			break;
		}	
		if (boundarySurface != null) {
			boundarySurface.setLod4MultiSurface(new MultiSurfaceProperty(new MultiSurface(geometry)));
			return new BoundarySurfaceProperty(boundarySurface);
		}

		return null;	
	}

}
