// body: FutureBuilder<DataSnapshot?>(

      //   future: firebaseService.getData('GratitudeLogs'), 
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Center(child: CircularProgressIndicator());
      //     }
      //     else if (snapshot.hasError) {
      //       return Center(child: Text('Error: ${snapshot.error}'));
      //     }
      //     else if (snapshot.hasData) {
      //        final DataSnapshot? data = snapshot.data;
      // if (data != null) {
        // Data exists; process it.  Note the extra null check!
        // return Text('Data: ${data.value}'); // Or your data display logic




        
    //   } else {
    //     // DataSnapshot is null (meaning data wasn't found or there was an error)
    //     return Text('No data found'); // Or other appropriate UI
    //   }
    // } else {
    //   return Text('Something went wrong'); // Should never happen with FutureBuilder
    // }
          
    //     }
    //   )
      